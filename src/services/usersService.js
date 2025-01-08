const pool = require('../db/db.js');

async function getEmployees(res) {
    try {
        const result = await pool.query(`SELECT * FROM employees;`);
        res.status(200).send(JSON.stringify(result.rows));
    } catch (error) {
        res.status(400).send("Error while fetching employees");
    }
}

async function getAdministrators(res) {
    try {
        const result = await pool.query(`SELECT * FROM administrators`);
        res.status(200).send(JSON.stringify(result.rows));
    } catch (error) {
        res.status(400).send("Error while fetching admins");
    }
}

async function updateEmployee(employeeId, data, res) {
    try {
        const result = await pool.query(
            `UPDATE employees 
             SET first_name = $1, last_name = $2, username = $3, password = $4, 
                 title_id = $5, employment_period = $6 
             WHERE id = $7 RETURNING *`,
            [
                data.first_name,
                data.last_name,
                data.username,
                data.password,
                data.title_id,
                data.employment_period,
                employeeId,
            ]
        );
        res.status(200).send(JSON.stringify(result.rows[0]));
    } catch (error) {
        res.status(400).send(error.message);
    }
}


module.exports = { getEmployees, getAdministrators , updateEmployee};
