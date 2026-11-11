const test = require('node:test');
const assert = require('node:assert/strict');
const { createFirestoreTodoRepo, initFirebase } = require('../src/config/firebase');

test('Firestore Todo Repository & Firebase Config TDD Suite', async (t) => {
  await t.test('initFirebase 可成功載入 serviceAccountKey.json 並回傳 authClient 與 todoRepo', () => {
    const initialized = initFirebase();
    assert.equal(initialized.projectId, 'cullio');
    assert.ok(initialized.authClient);
    assert.ok(initialized.todoRepo);
  });

  await t.test('createFirestoreTodoRepo 正確讀寫 users/{uid}/todos/{todoId} 子集合路徑', async () => {
    const recordedPaths = [];
    const mockDb = {
      collection(colName) {
        recordedPaths.push(colName);
        return {
          doc(uid) {
            recordedPaths.push(uid);
            return {
              collection(subCol) {
                recordedPaths.push(subCol);
                return {
                  async get() {
                    return {
                      docs: [
                        {
                          id: 'doc-1',
                          data: () => ({
                            title: 'Firestore 測試',
                            dueDate: '2026-11-15',
                            state: 'todo',
                            category: 'company',
                          }),
                        },
                      ],
                    };
                  },
                };
              },
            };
          },
        };
      },
    };

    const repo = createFirestoreTodoRepo(mockDb);
    const items = await repo.listByUser('uid-123');
    assert.deepEqual(recordedPaths, ['users', 'uid-123', 'todos']);
    assert.equal(items.length, 1);
    assert.equal(items[0].id, 'doc-1');
    assert.equal(items[0].title, 'Firestore 測試');
  });
});
