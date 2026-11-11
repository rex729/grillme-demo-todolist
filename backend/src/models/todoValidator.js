const ALLOWED_STATES = new Set(['todo', 'in progress', 'done']);
const ALLOWED_CATEGORIES = new Set(['company', 'personal', 'other']);
const DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/;

/**
 * 檢查 yyyy-mm-dd 是否為真實存在的日曆日期 (例如排除 2026-02-30)
 */
function isValidCalendarDate(dateStr) {
  if (!DATE_REGEX.test(dateStr)) return false;
  const [year, month, day] = dateStr.split('-').map(Number);
  const dt = new Date(Date.UTC(year, month - 1, day));
  return (
    dt.getUTCFullYear() === year &&
    dt.getUTCMonth() === month - 1 &&
    dt.getUTCDate() === day
  );
}

/**
 * 驗證 Todo 新增/更新請求資料
 * @param {object} payload
 * @returns {{ valid: boolean, data?: object, error?: string }}
 */
function validateTodoPayload(payload = {}) {
  const rawTitle = typeof payload.title === 'string' ? payload.title.trim() : '';
  if (!rawTitle) {
    return { valid: false, error: 'title 為必填且不可為空白字串' };
  }

  const dueDate = typeof payload.dueDate === 'string' ? payload.dueDate.trim() : '';
  if (!isValidCalendarDate(dueDate)) {
    return {
      valid: false,
      error: 'dueDate 格式必須為有效的 yyyy-mm-dd 日期（例如 2026-11-15）',
    };
  }

  const state = payload.state;
  if (!ALLOWED_STATES.has(state)) {
    return {
      valid: false,
      error: "state 僅允許 'todo', 'in progress', 'done'",
    };
  }

  const category = payload.category;
  if (!ALLOWED_CATEGORIES.has(category)) {
    return {
      valid: false,
      error: "category 僅允許 'company', 'personal', 'other'",
    };
  }

  return {
    valid: true,
    data: {
      title: rawTitle,
      dueDate,
      state,
      category,
    },
  };
}

module.exports = {
  ALLOWED_STATES,
  ALLOWED_CATEGORIES,
  validateTodoPayload,
};
