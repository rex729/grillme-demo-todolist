const express = require('express');
const cors = require('cors');
const { createAuthMiddleware } = require('./middleware/auth');
const { createTodoRouter } = require('./routes/todos');

/**
 * 建立 Express 應用程式（支援依賴注入以便 TDD 測試）
 * @param {{ authClient: object, todoRepo: object }} deps
 */
function createApp({ authClient, todoRepo }) {
  const app = express();

  app.use(cors());
  app.use(express.json());

  // 健康檢查端點 (免驗證)
  app.get('/health', (_req, res) => {
    res.status(200).json({ status: 'ok' });
  });

  // 掛載 /api/v1/todos (需通過 Firebase ID Token 驗證)
  app.use(
    '/api/v1/todos',
    createAuthMiddleware(authClient),
    createTodoRouter(todoRepo)
  );

  return app;
}

module.exports = { createApp };
