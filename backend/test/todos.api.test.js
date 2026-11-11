const test = require('node:test');
const assert = require('node:assert/strict');
const { Readable, Writable, Duplex } = require('node:stream');
const { createApp } = require('../src/app');

// 建立記憶體內假資料庫 (In-Memory Firestore Stub) 與假 Auth 驗證器，測試完整 API 行為與多租戶隔離
function createFakeDeps() {
  const store = new Map(); // uid -> Map(todoId -> docData)
  let seq = 1;

  const authClient = {
    async verifyIdToken(token) {
      if (token === 'valid-token-user-a') return { uid: 'user-a' };
      if (token === 'valid-token-user-b') return { uid: 'user-b' };
      throw new Error('Invalid token');
    },
  };

  const todoRepo = {
    async listByUser(uid) {
      const userMap = store.get(uid) || new Map();
      return Array.from(userMap.entries()).map(([id, data]) => ({
        id,
        ...data,
      }));
    },
    async createForUser(uid, todoData) {
      if (!store.has(uid)) store.set(uid, new Map());
      const id = `todo-${seq++}`;
      const now = new Date().toISOString();
      const record = {
        ...todoData,
        createdAt: now,
        updatedAt: now,
      };
      store.get(uid).set(id, record);
      return { id, ...record };
    },
    async updateForUser(uid, id, todoData) {
      const userMap = store.get(uid);
      if (!userMap || !userMap.has(id)) {
        return null;
      }
      const existing = userMap.get(id);
      const updated = {
        ...existing,
        ...todoData,
        updatedAt: new Date().toISOString(),
      };
      userMap.set(id, updated);
      return { id, ...updated };
    },
    async deleteForUser(uid, id) {
      const userMap = store.get(uid);
      if (userMap) {
        userMap.delete(id);
      }
    },
  };

  return { authClient, todoRepo };
}

/**
 * 記憶體內 Express 請求模擬器 (免開 TCP Port，高速且相容沙盒環境)
 */
function requestApp(app, path, { method = 'GET', headers = {}, body } = {}) {
  return new Promise((resolve, reject) => {
    const rawBody = body ? Buffer.from(body, 'utf8') : Buffer.alloc(0);
    const normalizedHeaders = {};
    for (const [k, v] of Object.entries(headers)) {
      normalizedHeaders[k.toLowerCase()] = v;
    }
    if (body && !normalizedHeaders['content-length']) {
      normalizedHeaders['content-length'] = String(rawBody.length);
    }

    let pushed = false;
    const req = new Readable({
      read() {
        if (!pushed) {
          pushed = true;
          if (rawBody.length > 0) this.push(rawBody);
          this.push(null);
        }
      },
    });
    req.url = path;
    req.method = method;
    req.headers = normalizedHeaders;
    const dummySocket = new Duplex({
      read() {},
      write(_c, _e, cb) {
        cb();
      },
    });
    req.connection = dummySocket;
    req.socket = dummySocket;

    const chunks = [];
    const resHeaders = {};
    const res = new Writable({
      write(chunk, _enc, cb) {
        chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
        cb();
      },
    });
    res.statusCode = 200;
    res.setHeader = (name, val) => {
      resHeaders[name.toLowerCase()] = val;
    };
    res.getHeader = (name) => resHeaders[name.toLowerCase()];
    res.removeHeader = (name) => {
      delete resHeaders[name.toLowerCase()];
    };
    res.writeHead = (code, hdrs) => {
      res.statusCode = code;
      if (hdrs) {
        for (const [k, v] of Object.entries(hdrs)) {
          res.setHeader(k, v);
        }
      }
      return res;
    };
    const origEnd = res.end.bind(res);
    res.end = (chunk, encoding, cb) => {
      if (chunk) {
        chunks.push(
          Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk, encoding)
        );
      }
      origEnd(() => {
        const text = Buffer.concat(chunks).toString('utf8');
        resolve({
          status: res.statusCode,
          headers: resHeaders,
          json: async () => (text ? JSON.parse(text) : {}),
        });
        if (cb) cb();
      });
    };

    try {
      app(req, res);
    } catch (err) {
      reject(err);
    }
  });
}

test('Todos RESTful API TDD Suite', async (t) => {
  const deps = createFakeDeps();
  const app = createApp(deps);

  await t.test('GET /health 免驗證回傳 200 ok', async () => {
    const res = await requestApp(app, '/health');
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.deepEqual(body, { status: 'ok' });
  });

  await t.test('未帶 Authorization Bearer Token 時回傳 401', async () => {
    const res = await requestApp(app, '/api/v1/todos');
    assert.equal(res.status, 401);
  });

  await t.test('帶入無效 Token 時回傳 401', async () => {
    const res = await requestApp(app, '/api/v1/todos', {
      headers: { Authorization: 'Bearer bad-token' },
    });
    assert.equal(res.status, 401);
  });

  let createdTodoId = '';

  await t.test('POST /api/v1/todos 新增合法的 Todo 回傳 201', async () => {
    const res = await requestApp(app, '/api/v1/todos', {
      method: 'POST',
      headers: {
        Authorization: 'Bearer valid-token-user-a',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        title: '撰寫 TDD 測試',
        dueDate: '2026-11-20',
        state: 'todo',
        category: 'company',
      }),
    });

    assert.equal(res.status, 201);
    const body = await res.json();
    assert.ok(body.data.id);
    assert.equal(body.data.title, '撰寫 TDD 測試');
    assert.equal(body.data.dueDate, '2026-11-20');
    assert.equal(body.data.state, 'todo');
    assert.equal(body.data.category, 'company');
    createdTodoId = body.data.id;
  });

  await t.test('POST /api/v1/todos 欄位格式錯誤時回傳 400', async () => {
    const res = await requestApp(app, '/api/v1/todos', {
      method: 'POST',
      headers: {
        Authorization: 'Bearer valid-token-user-a',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        title: '錯誤日期格式',
        dueDate: '11-20-2026',
        state: 'todo',
        category: 'company',
      }),
    });
    assert.equal(res.status, 400);
  });

  await t.test('多使用者資料隔離：User B 查不到 User A 的 Todo', async () => {
    const resA = await requestApp(app, '/api/v1/todos', {
      headers: { Authorization: 'Bearer valid-token-user-a' },
    });
    const bodyA = await resA.json();
    assert.equal(bodyA.data.length, 1);

    const resB = await requestApp(app, '/api/v1/todos', {
      headers: { Authorization: 'Bearer valid-token-user-b' },
    });
    const bodyB = await resB.json();
    assert.equal(bodyB.data.length, 0);
  });

  await t.test('PUT /api/v1/todos/:id 更新既有 Todo 回傳 200', async () => {
    const res = await requestApp(app, `/api/v1/todos/${createdTodoId}`, {
      method: 'PUT',
      headers: {
        Authorization: 'Bearer valid-token-user-a',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        title: '撰寫 TDD 測試 (已更新)',
        dueDate: '2026-11-21',
        state: 'done',
        category: 'personal',
      }),
    });

    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.data.title, '撰寫 TDD 測試 (已更新)');
    assert.equal(body.data.state, 'done');
    assert.equal(body.data.category, 'personal');
  });

  await t.test('PUT /api/v1/todos/:id 更新不存在的 ID 回傳 404', async () => {
    const res = await requestApp(app, '/api/v1/todos/not-found-id', {
      method: 'PUT',
      headers: {
        Authorization: 'Bearer valid-token-user-a',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        title: '不存在',
        dueDate: '2026-11-21',
        state: 'todo',
        category: 'other',
      }),
    });
    assert.equal(res.status, 404);
  });

  await t.test('DELETE /api/v1/todos/:id 刪除 Todo 後列表清空', async () => {
    const delRes = await requestApp(app, `/api/v1/todos/${createdTodoId}`, {
      method: 'DELETE',
      headers: { Authorization: 'Bearer valid-token-user-a' },
    });
    assert.equal(delRes.status, 200);

    const listRes = await requestApp(app, '/api/v1/todos', {
      headers: { Authorization: 'Bearer valid-token-user-a' },
    });
    const listBody = await listRes.json();
    assert.equal(listBody.data.length, 0);
  });
});
