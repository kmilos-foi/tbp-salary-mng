const pool = require('../db/db.js');
const logService = require('./logService.js')

async function getHours(res) {
    try {
        const result = await pool.query(
            `SELECT * FROM hours;`
        );
        res.status(200).send(JSON.stringify(result.rows));
    } catch (error) {
        res.status(400).send(error.message);
    }
}

async function insertWorkTime(req, res) {
    let worktime = req.body;
    worktime.day = new Date(worktime.day);
    worktime.day = worktime.day.toISOString().split('T')[0];
    try {
        const result = await pool.query(
            `INSERT INTO work_times VALUES ($1, $2, $3)`,
            [worktime.hours, req.session.userId, worktime.day]
        );
        await logService.insertLog("Korisnik s id-om: " + req.session.userId + " uspješno upisao sate")
        res.status(201).send("Sati su upisani!");
    } catch (error) {
        await logService.insertLog("Korisnik s id-om: " + req.session.userId + " neuspješno upisao sate")
        res.status(400).send(error.message);
    }
}


module.exports = { getHours, insertWorkTime};
