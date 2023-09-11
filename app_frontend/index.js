const express = require("express");
const app = express();
const path = require("path");

app.use("/", express.static(path.join(__dirname, "public")));

app.listen(5000, () => {
    console.log(`Running on http://localhost:5000`);
});
