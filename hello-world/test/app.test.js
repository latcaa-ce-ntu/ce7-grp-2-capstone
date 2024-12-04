import request from "supertest";
import { expect } from "chai"; // Import expect from Chai
import app from "../app.js"; // Ensure the correct path and extension

describe("GET /", () => {
  it("should return Hello, World!", async () => {
    const res = await request(app).get("/");
    expect(res.statusCode).to.equal(200); // Use Chai's expect
    expect(res.text).to.equal("Hello, World!"); // Use Chai's expect
  });
});
