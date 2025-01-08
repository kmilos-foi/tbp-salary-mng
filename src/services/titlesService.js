const pool = require('../db/db.js');

async function getTitles(res) {
    try {
        const result = await pool.query(`SELECT * FROM titles;`);
        res.status(200).send(JSON.stringify(result.rows));
    } catch (error) {
        res.status(400).send("Error while fetching employees");
    }
}
module.exports = { getTitles };
