const pool = require('../db/db.js');
const logService = require('./logService.js')

async function getPayrollProcesses(res) {
    try {
        const result = await pool.query(
            `SELECT * FROM payroll_processes;`
        );
        res.status(200).send(JSON.stringify(result.rows));
    } catch (error) {
        res.status(500).send({ message: "Error fetching hours" });
    }
}

async function insertPayrollProcess(req, res) {
    let payroll = req.body;
    payroll.date = new Date(payroll.date);
    try {
        const result = await pool.query(
            `INSERT INTO payroll_processes(administrator_id, date) VALUES ($1, $2) RETURNING id`,
            [req.session.userId, payroll.date]
        );
        await logService.insertLog("Admin s id-om: " + req.session.userId + " uspješno kreirao proces obračun")

        const payrollProcessId = result.rows[0].id;
        const month = payroll.date.getMonth() + 1;
        const year = payroll.date.getFullYear();
        await calculateAndInsertPayrolls(payrollProcessId, month, year);

        res.status(201).send("Sati su upisani!");
    } catch (error) {
        await logService.insertLog("Admin s id-om: " + req.session.userId + " neuspješno kreirao proces obračun")
        res.status(400).send(error.message);
    }
}

async function calculateAndInsertPayrolls(payrollProcessId, month, year) {
    const totalHoursQuery = `
    SELECT 
        wt.employee_id, 
        SUM(h.hour) AS total_hours
    FROM work_times wt
    JOIN hours h ON wt.hour_id = h.id
    WHERE EXTRACT(MONTH FROM wt.day) = $1 
    AND EXTRACT(YEAR FROM wt.day) = $2
    GROUP BY wt.employee_id;
    `;

    const result = await pool.query(totalHoursQuery, [month, year]);

    for (const row of result.rows) {
        const employeeId = row.employee_id;
        const totalHours = row.total_hours;

        const salaryBonusQuery = `
        SELECT t.salary_bonus
        FROM employees e
        JOIN titles t ON e.title_id = t.id
        WHERE e.id = $1
        `;
        const bonusResult = await pool.query(salaryBonusQuery, [employeeId]);

        const salaryBonus = bonusResult.rows[0].salary_bonus;

        const monthSalary = 100 * totalHours + salaryBonus;
        await pool.query(
            `INSERT INTO payrolls (payroll_processes_id, employee_id, month_salary, total_hours)
             VALUES ($1, $2, $3, $4)`,
            [payrollProcessId, employeeId, monthSalary, totalHours]
        );
    }
}

async function getPayrollsByProcessId(id, res) {
    try {
        const result = await pool.query(
            `SELECT 
                p.employee_id,
                p.month_salary,
                p.total_hours,
                e.first_name,
                e.last_name,
                t.name AS title_name
             FROM payrolls p
             JOIN employees e ON p.employee_id = e.id
             JOIN titles t ON e.title_id = t.id
             WHERE p.payroll_processes_id = $1`,
            [id]
        );
        res.status(200).send(JSON.stringify(result.rows));
    } catch (error) {
        console.error("Error fetching payrolls:", error);
        res.status(500).send({ message: "Error fetching payrolls" });
    }
}       

async function getPayrollData(processId, employeeId, res) {
    try {
        const processResult = await pool.query(
            `SELECT date FROM payroll_processes WHERE id = $1`,
            [processId]
        );

        if (processResult.rows.length === 0) {
            return res.status(404).send({ message: "Proces nije pronađen." });
        }

        const processDate = new Date(processResult.rows[0].date);
        const month = processDate.getMonth() + 1;
        const year = processDate.getFullYear();

        const workTimesResult = await pool.query(
            `
            SELECT 
                h.hour, 
                e.first_name,
                e.last_name, 
                wt.day
            FROM work_times wt
            JOIN hours h ON wt.hour_id = h.id
            JOIN employees e ON wt.employee_id = e.id
            WHERE EXTRACT(MONTH FROM wt.day) = $1
              AND EXTRACT(YEAR FROM wt.day) = $2
              AND wt.employee_id = $3
            `,
            [month, year, employeeId]
        );

        res.status(200).send(JSON.stringify(workTimesResult.rows));
    } catch (error) {
        res.status(500).send({ message: "Error fetching payroll data" });
    }
}


module.exports = {getPayrollProcesses, insertPayrollProcess, getPayrollsByProcessId, getPayrollData};
