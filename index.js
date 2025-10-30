// index.js
const http = require('http');
const port = process.env.PORT || 8080;

const requestHandler = (req, res) => {
  if (req.url === '/healthz') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    return res.end('OK');
  }
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello from Node app on ' + (process.env.INSTANCE_ID || 'unknown'));
};

const server = http.createServer(requestHandler);
server.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
