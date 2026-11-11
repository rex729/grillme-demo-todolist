const { initFirebase } = require('./src/config/firebase');
const { createApp } = require('./src/app');

const port = process.env.PORT || 8080;
const { authClient, todoRepo, projectId } = initFirebase();
const app = createApp({ authClient, todoRepo });

app.listen(port, () => {
  console.log(
    `Node.js Express 伺服器啟動於 http://localhost:${port} (Firebase Project: ${projectId})`
  );
});
