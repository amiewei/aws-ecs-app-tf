const express = require("express");
const app = express();
const path = require("path");

app.get("/", async (req, res) => {
    const filePath = path.join(__dirname, "public", "index.html");
    res.sendFile(filePath);
});

app.listen(5000, () => {
    console.log(`Running on http://localhost:5000`);
});
