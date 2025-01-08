const express = require("express");
const session = require("express-session");
const path = require("path");

const authService = require("./services/authService.js")
const worktimeService = require("./services/workTimesService.js")
const payrollService = require("./services/payrollService.js")
const logService = require("./services/logService.js")
const usersService = require("./services/usersService.js")
const titlesService = require("./services/titlesService.js")

const server = express();
const port = process.env.PORT || 12000;

startServer();

function startServer() {
    configureServer();
    serveStaticFiles();
  
    serveHtml();
    serveServices();
    server.use((req, res) => {
        res.status(404);
        res.json({ message: "Krivi url" });
    });
    
    server.listen(port, () => {
        console.log(`Server pokrenut na portu: ${port}`);
    });
}  

function configureServer() {
    server.use(express.urlencoded({ extended: true }));
    server.use(express.json());
    configureSession();
    server.use((req, res, next) => {
      if (req.path==='/employee-login' || req.path==='/admin-login' || req.path === '/login' || req.path.startsWith('/css') || req.path.startsWith('/js') || req.path.startsWith('/images')) {
          return next();
      }
    
      if (req.session && req.session.userId) {
         return next();
      }
      return res.redirect('/login');
    });
}

function configureSession() {
    server.use(
        session({
            secret: "123abcrgrjsuiguihsfiu",
            saveUninitialized: true,
            cookie: {
                maxAge: 10000 * 60 * 60,
            },
            resave: false,
        })
    );
}

function serveStaticFiles() {
    server.use("/css", express.static(path.join(__dirname, "../public/css")));
    server.use("/js", express.static(path.join(__dirname, "../public/js")));
    server.use(
        "/images",
        express.static(path.join(__dirname, "../public/images"))
    );
}

function serveHtml() {
    server.get("/index", (req, res) => {
        if (req.session.role == "employee") {
            res.redirect("/index-employee");
        } else {
            res.redirect("/index-admin");
        }
    });
    server.get("/index-employee", (req, res) => {
        res.sendFile(path.join(__dirname, "../public/html/index-employee.html"));
    });
    server.get("/index-admin", (req, res) => {
        res.sendFile(path.join(__dirname, "../public/html/index-admin.html"));
    });
    server.get("/log", (req, res) => {
        res.sendFile(path.join(__dirname, "../public/html/log.html"));
    });
    server.get("/process-details", (req, res) => {
        res.sendFile(path.join(__dirname, "../public/html/process-details.html"));
    });
    server.get("/payroll-details", (req, res) => {
        res.sendFile(path.join(__dirname, "../public/html/payroll-details.html"));
    });
    server.get("/login", (req, res) => {
        res.sendFile(path.join(__dirname, "../public/html/login.html"));
    });
    server.get("/users", (req, res) => {
        res.sendFile(path.join(__dirname, "../public/html/users.html"));
    });
    server.get("/employee-details", (req, res) => {
        res.sendFile(path.join(__dirname, "../public/html/employee-details.html"));
    });
}

function serveServices() {
    server.get('/logout', (req, res) => {
        req.session.destroy((err) => {
            res.redirect("/login");
        });
    });

    server.post("/employee-login", (req, res) => {
      authService.checkEmployeeLogin(req, res);
    });
    server.post("/admin-login", (req, res) => {
        authService.checkAdminLogin(req, res);
    });

    server.get("/hours", (req, res) => {
        worktimeService.getHours(res);
    });

    server.get("/titles", (req, res) => {
        titlesService.getTitles(res);
    });

    server.get("/employees", (req, res) => {
        usersService.getEmployees(res);
    });

    server.get("/administrators", (req, res) => {
        usersService.getAdministrators(res);
    });

    server.get("/logs", (req, res) => {
        logService.getLogs(res);
    });

    server.get("/payroll-processes", (req, res) => {
        payrollService.getPayrollProcesses(res);
    });

    server.get("/payrolls", (req, res) => {
        const processId = req.query.id;
        payrollService.getPayrollsByProcessId(processId, res);
    });

    server.get("/payroll", (req, res) => {
        const processId = req.query.process;
        const employeeId = req.query.employee;
        payrollService.getPayrollData(processId, employeeId, res);
    });

    server.post("/worktime", (req, res) => {
        worktimeService.insertWorkTime(req, res);
    });
    server.post("/payroll-process", (req, res) => {
        payrollService.insertPayrollProcess(req, res);
    });

    server.put("/users/:id", async (req, res) => {
        const employeeId = req.params.id;
        const data = req.body;
        usersService.updateEmployee(employeeId, data, res);
    });
}
