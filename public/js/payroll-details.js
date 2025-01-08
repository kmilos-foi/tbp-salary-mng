window.addEventListener("DOMContentLoaded", async () => {
    const urlParams = new URLSearchParams(window.location.search);
    const employeeId = urlParams.get("employee");
    const processId = urlParams.get("process");
    await displayPayrollDetails(employeeId, processId);
});

async function displayPayrollDetails(employeeId, processId) {
    let response = await fetch(`/payroll?employee=${employeeId}&process=${processId}`)
    let payrollData = await response.json();

    createPayrollTable(payrollData);
}

function createPayrollTable(workTimesData) {
    const tbody = document.getElementById("tbody");
    tbody.innerHTML = "";

    workTimesData.forEach((data) => {
        const tr = document.createElement("tr");

        const tdEmployee = document.createElement("td");
        tdEmployee.textContent = `${data.first_name} ${data.last_name}`;
        tr.appendChild(tdEmployee);

        const tdDay = document.createElement("td");
        const formattedDay = data.day.split("T")[0];
        tdDay.textContent = formattedDay;
        tr.appendChild(tdDay);

        const tdHours = document.createElement("td");
        tdHours.textContent = data.hour;
        tr.appendChild(tdHours);

        tbody.appendChild(tr);
    });
}
