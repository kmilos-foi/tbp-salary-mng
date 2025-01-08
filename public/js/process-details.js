var processId;

window.addEventListener("DOMContentLoaded", async () => {
    const urlParams = new URLSearchParams(window.location.search);
    processId = urlParams.get("process");
    const year = urlParams.get("year");
    const month = urlParams.get("month");
    displayProcessDetails(month, year);
    await displayPayrollsTable(processId)
});

function displayProcessDetails(month, year) {
    const processDetailsContainer = document.getElementById("procName");
    let title = `Obračun iz ${month}. mjeseca ${year}. godine`;
    processDetailsContainer.innerText = title;
}

async function displayPayrollsTable(processId) {
    let response = await fetch(`/payrolls?id=${processId}`)
    let payrolls = await response.json();

    createPayrollTable(payrolls);
}

function createPayrollTable(payrolls) {
    const tbody = document.getElementById("tbody");
    tbody.innerHTML = "";

    payrolls.forEach((payroll) => {
        const tr = document.createElement("tr");

        const tdEmployee = document.createElement("td");
        tdEmployee.textContent = `${payroll.first_name} ${payroll.last_name}`;
        tr.appendChild(tdEmployee);

        const tdTitle = document.createElement("td");
        tdTitle.textContent = `${payroll.title_name}`;
        tr.appendChild(tdTitle);

        const tdMonthSalary = document.createElement("td");
        tdMonthSalary.textContent = `${payroll.month_salary}`;
        tr.appendChild(tdMonthSalary);

        const tdTotalHours = document.createElement("td");
        tdTotalHours.textContent = `${payroll.total_hours}`;

        tr.addEventListener("click", () => {
            openPayroll(payroll.employee_id);
        });

        tr.appendChild(tdTotalHours);

        tbody.appendChild(tr);
    });
}

function openPayroll(employee_id) {
    window.location.href=`/payroll-details?employee=${employee_id}&process=${processId}`
}
