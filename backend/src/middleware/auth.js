/**
 * 建立 Firebase ID Token 驗證中介軟體
 * @param {{ verifyIdToken: (token: string) => Promise<{ uid: string }> }} authClient
 */
function createAuthMiddleware(authClient) {
  return async function authMiddleware(req, res, next) {
    const authHeader = req.headers.authorization || '';
    if (!authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: '缺少或無效的 Authorization Bearer Header',
      });
    }

    const idToken = authHeader.slice('Bearer '.length).trim();
    if (!idToken) {
      return res.status(401).json({
        error: 'ID Token 不可為空',
      });
    }

    try {
      const decoded = await authClient.verifyIdToken(idToken);
      req.uid = decoded.uid;
      return next();
    } catch (err) {
      return res.status(401).json({
        error: '無效或已過期的 Firebase ID Token',
      });
    }
  };
}

module.exports = { createAuthMiddleware };
