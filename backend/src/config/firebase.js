const fs = require('node:fs');
const path = require('node:path');
const admin = require('firebase-admin');

const DEFAULT_PROJECT_ID = 'cullio';

/**
 * 初始化 Firebase Admin SDK (Auth 與 Firestore)
 * 優先順序：
 * 1. 環境變數 GOOGLE_APPLICATION_CREDENTIALS 指定的金鑰檔案
 * 2. backend/serviceAccountKey.json
 * 3. Application Default Credentials (ADC)
 */
function initFirebase() {
  const projectId = process.env.FIREBASE_PROJECT_ID || DEFAULT_PROJECT_ID;
  const localKeyPath = path.resolve(__dirname, '../../serviceAccountKey.json');

  let credential;
  if (
    process.env.GOOGLE_APPLICATION_CREDENTIALS &&
    fs.existsSync(process.env.GOOGLE_APPLICATION_CREDENTIALS)
  ) {
    const serviceAccount = require(path.resolve(
      process.env.GOOGLE_APPLICATION_CREDENTIALS
    ));
    credential = admin.credential.cert(serviceAccount);
  } else if (fs.existsSync(localKeyPath)) {
    const serviceAccount = require(localKeyPath);
    credential = admin.credential.cert(serviceAccount);
  } else {
    credential = admin.credential.applicationDefault();
  }

  if (!admin.apps.length) {
    admin.initializeApp({
      credential,
      projectId,
    });
  }

  const authClient = admin.auth();
  const db = admin.firestore();
  const todoRepo = createFirestoreTodoRepo(db);

  return { authClient, todoRepo, projectId };
}

/**
 * 建立基於 Firestore (users/{uid}/todos/{todoId}) 的資料存取層
 * @param {FirebaseFirestore.Firestore} db
 */
function createFirestoreTodoRepo(db) {
  function userTodosCol(uid) {
    return db.collection('users').doc(uid).collection('todos');
  }

  return {
    async listByUser(uid) {
      const snapshot = await userTodosCol(uid).get();
      return snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
    },

    async createForUser(uid, todoData) {
      const now = new Date().toISOString();
      const record = {
        ...todoData,
        createdAt: now,
        updatedAt: now,
      };
      const docRef = await userTodosCol(uid).add(record);
      return {
        id: docRef.id,
        ...record,
      };
    },

    async updateForUser(uid, id, todoData) {
      const docRef = userTodosCol(uid).doc(id);
      const docSnap = await docRef.get();
      if (!docSnap.exists) {
        return null;
      }
      const existing = docSnap.data();
      const updated = {
        ...existing,
        ...todoData,
        updatedAt: new Date().toISOString(),
      };
      await docRef.set(updated);
      return {
        id: docRef.id,
        ...updated,
      };
    },

    async deleteForUser(uid, id) {
      await userTodosCol(uid).doc(id).delete();
    },
  };
}

module.exports = {
  DEFAULT_PROJECT_ID,
  initFirebase,
  createFirestoreTodoRepo,
};
