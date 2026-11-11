const express = require('express');
const { validateTodoPayload } = require('../models/todoValidator');

/**
 * 建立 Todo RESTful 路由
 * @param {{
 *   listByUser: (uid: string) => Promise<Array<object>>,
 *   createForUser: (uid: string, data: object) => Promise<object>,
 *   updateForUser: (uid: string, id: string, data: object) => Promise<object|null>,
 *   deleteForUser: (uid: string, id: string) => Promise<void>
 * }} todoRepo
 */
function createTodoRouter(todoRepo) {
  const router = express.Router();

  // GET /api/v1/todos
  router.get('/', async (req, res) => {
    try {
      const todos = await todoRepo.listByUser(req.uid);
      return res.status(200).json({ data: todos });
    } catch (err) {
      return res.status(500).json({
        error: `讀取待辦事項失敗: ${err.message}`,
      });
    }
  });

  // POST /api/v1/todos
  router.post('/', async (req, res) => {
    const validation = validateTodoPayload(req.body);
    if (!validation.valid) {
      return res.status(400).json({ error: validation.error });
    }

    try {
      const created = await todoRepo.createForUser(req.uid, validation.data);
      return res.status(201).json({ data: created });
    } catch (err) {
      return res.status(500).json({
        error: `新增待辦事項失敗: ${err.message}`,
      });
    }
  });

  // PUT /api/v1/todos/:id
  router.put('/:id', async (req, res) => {
    const validation = validateTodoPayload(req.body);
    if (!validation.valid) {
      return res.status(400).json({ error: validation.error });
    }

    try {
      const updated = await todoRepo.updateForUser(
        req.uid,
        req.params.id,
        validation.data
      );
      if (!updated) {
        return res.status(404).json({ error: '找不到指定的待辦事項' });
      }
      return res.status(200).json({ data: updated });
    } catch (err) {
      return res.status(500).json({
        error: `更新待辦事項失敗: ${err.message}`,
      });
    }
  });

  // DELETE /api/v1/todos/:id
  router.delete('/:id', async (req, res) => {
    try {
      await todoRepo.deleteForUser(req.uid, req.params.id);
      return res.status(200).json({ message: 'deleted' });
    } catch (err) {
      return res.status(500).json({
        error: `刪除待辦事項失敗: ${err.message}`,
      });
    }
  });

  return router;
}

module.exports = { createTodoRouter };
