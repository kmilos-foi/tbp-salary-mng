window.addEventListener("DOMContentLoaded", () => {
    getLogs();
});
  

async function getLogs() {
    let response = await fetch("/logs");
    let logs = await response.json();
    createLogTable(logs);
}

function createLogTable(logs) {
    const tbody = document.getElementById("tbody");
    tbody.innerHTML = "";

    logs.forEach((log) => {
        const tr = document.createElement("tr");

        const tdMessage = document.createElement("td");
        tdMessage.textContent = `${log.message}`;
        tr.appendChild(tdMessage);

        const tdTimestamp = document.createElement("td");
        tdTimestamp.textContent = log.timestamp;
        tr.appendChild(tdTimestamp);

        tbody.appendChild(tr);
    });
}