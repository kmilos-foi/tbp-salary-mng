let userForm;
window.addEventListener("DOMContentLoaded", async () => {
    userForm = document.getElementById("userForm");
    const urlParams = new URLSearchParams(window.location.search);
    const employeeData = urlParams.get("employee");
    const employee = JSON.parse(decodeURIComponent(employeeData));
    await setUpdateButton(employee.id);
    await fillData(employee)
});

async function fillData(employee) {
    document.getElementById("firstName").value = employee.first_name || "";
    document.getElementById("lastName").value = employee.last_name || "";
    document.getElementById("username").value = employee.username || "";
    document.getElementById("txtPassword").value = employee.password || "";

    const [startDate, endDate] = employee.employment_period
        .replace("[", "") 
        .replace(")", "")
        .split(",");

    document.getElementById("startDate").value = startDate || "";
    document.getElementById("endDate").value = endDate || "";

    let response = await fetch("/titles");
    let titles = await response.json();
    setTitle(titles, employee.title_id);
}

function setTitle(titles, selectedTitleId) {
    const select = document.getElementById("title");
    select.innerHTML = "";

    titles.forEach(title => {
        const option = document.createElement("option");
        option.value = title.id;
        option.textContent = title.name;
        select.appendChild(option);
    });
    select.value = selectedTitleId;
}


async function setUpdateButton(id) {
    document.getElementById("btnUpdate").addEventListener('click', async (e) => {
        e.preventDefault();
        if(!userForm.checkValidity()) {
            console.log(userForm.checkValidity())
            userForm.reportValidity();
            return
        }
        const firstName = document.getElementById("firstName").value;
        const lastName = document.getElementById("lastName").value;
        const username = document.getElementById("username").value;
        const password = document.getElementById("txtPassword").value;
        const titleId = document.getElementById("title").value;
        const startDate = document.getElementById("startDate").value;
        const endDate = document.getElementById("endDate").value;

        const updatedEmployee = {
            first_name: firstName,
            last_name: lastName,
            username: username,
            password: password,
            title_id: titleId,
            employment_period: `[${startDate},${endDate})`,
        };

        let response = await fetch(`/users/${id}`, {
            method: "PUT",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify(updatedEmployee),
        });
        if(response.ok) {
            window.location.href = `/users`;
        } else {
            const errorData = await response.text();
            alert(`Greška prilikom ažuriranja: ${errorData || "Nepoznata greška"}`);
        }
    });
}