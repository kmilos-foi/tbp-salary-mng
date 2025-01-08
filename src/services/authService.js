const pool = require('../db/db.js');
const logService = require('./logService.js')

async function checkEmployeeLogin(req, res) {
    try {
        await logService.insertLog("Korisnik s korimenom: " + req.body.username + " se pokušao ulogirati")
        const result = await pool.query(
            'SELECT check_employee_login($1, $2) AS success',
            [req.body.username, req.body.password]
        );
        if (result.rows[0].success) {
            await logService.insertLog("Korisnik s korimenom: " + req.body.username + " se uspješno ulogirao")

            const userResult = await pool.query(
                'SELECT id FROM employees WHERE username = $1',
                [req.body.username]
            )
            const userId = userResult.rows[0].id;
            req.session.userId = userId;
            req.session.role = "employee";

            res.status(200).send("Uspješna prijava");
        } else {
            await logService.insertLog("Korisnik s korimenom: " + req.body.username + " se neuspješno ulogirao")
            res.status(400).send("Neuspješna prijava");
        }
    } catch (error) {
        console.log(error)
    }
}

async function checkAdminLogin(req, res) {
    try {
        const result = await pool.query(
            'SELECT check_admin_login($1, $2) AS success',
            [req.body.username, req.body.password]
        );
        if (result.rows[0].success) {

            const userResult = await pool.query(
                'SELECT id FROM administrators WHERE username = $1',
                [req.body.username]
            )
            const userId = userResult.rows[0].id;
            req.session.userId = userId;
            req.session.role = "admin";

            res.status(200).send("Uspješna prijava");
        } else {
            res.status(400).send("Neuspješna prijava");
        }
    } catch (error) {
    }
}

module.exports = { checkEmployeeLogin, checkAdminLogin };
