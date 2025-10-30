const express = require('express');
const app = express();
const port = process.env.PORT || 8080;
const instanceId = process.env.INSTANCE_ID || 'Unknown Instance';
const version = 'v1.0.0'; // <-- CHANGE THIS VERSION FOR DEPLOYMENTS!

app.get('/', (req, res) => {
  res.send(`
    <h1>Hello from Node App!</h1>
    <p>Version: ${version}</p>
    <p>Instance ID: ${instanceId}</p>
  `);
});

app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});
