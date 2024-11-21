const request = require("supertest");
const express = require("express");

// Import the app from your main file (adjust the path as necessary)
const app = require("../index"); // Change this to the path of your main app file

describe("GET /", () => {
  it("should return Hello from ce7-grp-2!", (done) => {
    request(app).get("/").expect(200).expect("Hello from ce7-grp-2!", done);
  });
});

describe("GET /test", () => {
  it("should return Hello from /test ce7-grp-2!", (done) => {
    request(app)
      .get("/test")
      .expect(200)
      .expect("Hello from /test ce7-grp-2!", done);
  });
});

describe("GET /welcome", () => {
  it("should return Hello from /welcome ce7-grp-2!!", (done) => {
    request(app)
      .get("/welcome")
      .expect(200)
      .expect("Hello from /welcome ce7-grp-2!!", done);
  });
});
