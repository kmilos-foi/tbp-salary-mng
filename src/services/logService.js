const pool = require('../db/db.js');

async function getLogs(res) {
    try {
        const result = await pool.query(`SELECT * FROM log`);
        res.status(200).send(JSON.stringify(result.rows));
    } catch (error) {
        res.status(400).send("Error while fetching log");
    }
}

async function insertLog(message) {
    try {
        const result = await pool.query(
            `INSERT INTO log (message)
            VALUES ($1)`,
           [message]
        );
    } catch (error) {
        console.log("Error log service")
    }
}

module.exports = {getLogs, insertLog};
