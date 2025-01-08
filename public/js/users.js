window.addEventListener("DOMContentLoaded", async () => {
    await getEmployees();
    await getAdministrators();
});
  

async function getEmployees() {
        let response = await fetch("/employees");
        let employees = await response.json();
        createEmployeesTable(employees);
}

async function getAdministrators() {
    let response = await fetch("/administrators");
    let admins = await response.json();
    createAdministratorsTable(admins);
}

function createEmployeesTable(employees) {
    const tbody = document.getElementById("employeesTbody");
    tbody.innerHTML = "";

    employees.forEach((employee) => {
        const tr = document.createElement("tr");

        const tdName = document.createElement("td");
        tdName.textContent = `${employee.first_name} ${employee.last_name}`;
        tr.appendChild(tdName);
        tbody.appendChild(tr);

        const tdUsername = document.createElement("td");
        tdUsername.textContent = `${employee.username}`;
        tr.appendChild(tdUsername);
        tbody.appendChild(tr);

        const tdPassword = document.createElement("td");
        tdPassword.textContent = `${employee.password}`;
        tr.appendChild(tdPassword);
        tbody.appendChild(tr);

        const tdPeriod = document.createElement("td");
        tdPeriod.textContent = `${employee.employment_period}`;
        tr.appendChild(tdPeriod);
        tbody.appendChild(tr);

        tr.addEventListener('click',()=>{
            openEmployee(employee);
        })
    });
}

async function createAdministratorsTable(administrators) {
    const tbody = document.getElementById("adminTbody");
    tbody.innerHTML = "";

    administrators.forEach((admin) => {
        const tr = document.createElement("tr");

        const tdName = document.createElement("td");
        tdName.textContent = `${admin.first_name} ${admin.last_name}`;
        tr.appendChild(tdName);

        const tdUsername = document.createElement("td");
        tdUsername.textContent = admin.username;
        tr.appendChild(tdUsername);

        const tdPassword = document.createElement("td");
        tdPassword.textContent = admin.password;
        tr.appendChild(tdPassword);

        tbody.appendChild(tr);
    });
}

function openEmployee(employee) {
    const encodedEmployee = encodeURIComponent(JSON.stringify(employee));
    window.location.href = `/employee-details?employee=${encodedEmployee}`;
}