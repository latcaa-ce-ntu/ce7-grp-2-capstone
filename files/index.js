// before rum
//npm install express

// to run
// npm start

"use strict";

const express = require("express");

// Constants
const PORT = 8080;
const HOST = "0.0.0.0";
const OS = require("os");
const ENV = "DEV";

// App
const app = express();
app.get("/", (req, res) => {
  res.statusCode = 200;
  const msg = "Hello from ce7-grp-2!";
  res.send(msg);
});

app.get("/test", (req, res) => {
  res.statusCode = 200;
  const msg = "Hello from /test ce7-grp-2!";
  res.send(msg);
});

app.get("/welcome", (req, res) => {
  res.statusCode = 200;
  const msg = "Hello from /welcome ce7-grp-2!";
  res.send(msg);
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);
