window.addEventListener("DOMContentLoaded", () => {
    getPayrollProcesses()
    setSubmitButton();
});
  
function setSubmitButton() {
    let button = document.getElementById("btnSubmit");
    button.addEventListener('click',async (e)=>{
        e.preventDefault();
        let picker = document.getElementById("monthPicker");
        console.log(picker.value)
        let body = {
            "date":picker.value,
          }
        
          if (!picker.value) {
              alert("Odaberite mjesec!");
              return;
          }
        
          let response = await fetch("/payroll-process", {
              method: "POST",
              headers: {
                  "Content-Type": "application/json",
              },
              body: JSON.stringify(body),
          });
          getPayrollProcesses();
    })
}

async function getPayrollProcesses() {
    let response = await fetch("/payroll-processes");
    let processes = await response.json();
    createProcessesTable(processes);
}


function createProcessesTable(processes) {
    const tbody = document.getElementById("tbody");
    tbody.innerHTML = "";

    processes.forEach((process) => {
        const tr = document.createElement("tr");

        const tdDate = document.createElement("td");

        const dateParts = process.date.split("-"); 
        const monthAndYear = `Obračun iz ${dateParts[1]}. mjeseca ${dateParts[0]}. godine`;
        tdDate.textContent = monthAndYear;

        tr.addEventListener("click", () => {
            openProcess(process, dateParts[0], dateParts[1]);
        });

        tr.appendChild(tdDate);

        tbody.appendChild(tr); 
    });
}

function openProcess(process, year, month) {
    window.location.href=`/process-details?process=${process.id}&year=${year}&month=${month}`
}