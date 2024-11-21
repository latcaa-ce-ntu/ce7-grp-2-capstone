"use strict";

import express from "express";
const app = express();
const PORT = process.env.PORT || 8080;

// Define a simple route
app.get("/", (req, res) => {
  res.status(200).send("Hello, World!");
});

// Start the server only if this file is run directly
if (import.meta.url === `file://${process.argv[1]}`) {
  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

// Export the app as the default export
export default app; // This line makes it a default export
