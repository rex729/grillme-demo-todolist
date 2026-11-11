const test = require('node:test');
const assert = require('node:assert/strict');
const { validateTodoPayload } = require('../src/models/todoValidator');

test('TodoValidator TDD Suite', async (t) => {
  await t.test('通過合法的 Todo 欄位並自動去除 title 前後空白', () => {
    const result = validateTodoPayload({
      title: '  完成專案簡報  ',
      dueDate: '2026-11-15',
      state: 'in progress',
      category: 'company',
    });

    assert.equal(result.valid, true);
    assert.deepEqual(result.data, {
      title: '完成專案簡報',
      dueDate: '2026-11-15',
      state: 'in progress',
      category: 'company',
    });
  });

  await t.test('拒絕空白或缺失的 title', () => {
    const res1 = validateTodoPayload({
      title: '   ',
      dueDate: '2026-11-15',
      state: 'todo',
      category: 'personal',
    });
    assert.equal(res1.valid, false);
    assert.match(res1.error, /title/i);
  });

  await t.test('拒絕非 yyyy-mm-dd 格式或無效日曆日期的 dueDate', () => {
    const badFormat = validateTodoPayload({
      title: '繳費',
      dueDate: '2026/11/15',
      state: 'todo',
      category: 'personal',
    });
    assert.equal(badFormat.valid, false);
    assert.match(badFormat.error, /dueDate/i);

    const badCalendarDate = validateTodoPayload({
      title: '繳費',
      dueDate: '2026-02-30',
      state: 'todo',
      category: 'personal',
    });
    assert.equal(badCalendarDate.valid, false);
    assert.match(badCalendarDate.error, /dueDate/i);
  });

  await t.test('僅允許 todo, in progress, done 三種 state', () => {
    const res = validateTodoPayload({
      title: '測試',
      dueDate: '2026-11-15',
      state: 'pending',
      category: 'personal',
    });
    assert.equal(res.valid, false);
    assert.match(res.error, /state/i);
  });

  await t.test('僅允許 company, personal, other 三種 category', () => {
    const res = validateTodoPayload({
      title: '測試',
      dueDate: '2026-11-15',
      state: 'done',
      category: 'school',
    });
    assert.equal(res.valid, false);
    assert.match(res.error, /category/i);
  });
});
