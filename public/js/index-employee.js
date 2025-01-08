let lblError; 

window.addEventListener("DOMContentLoaded", async () => {
  lblError = document.getElementById("lblError");
  let hours = await getHours();
  populateDropDownWithHours(hours);

  let button = document.getElementById("btnSubmit");
  button.addEventListener('click', async (e) => {
    e.preventDefault();
    let dropdown = document.getElementById("dropdown");
    let hours = dropdown.value;
  
    let datePicker = document.getElementById("datePicker");
    let day = datePicker.value;

    let body = {
      "hours":hours,
      "day": day
    }
  
    if (!hours || !day) {
        alert("Molimo popunite sve podatke!");
        return;
    }
  
    let response = await fetch("/worktime", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
    });

    if (response.status === 201) {
      lblError.style.color = 'green';
    } else {
    lblError.style.color = 'red';
    }
    
    let message = await response.text();
    lblError.innerText = message;
  });

});

async function getHours() {
  let response = await fetch("/hours");
  let hours = await response.json();
  return hours;
}

function populateDropDownWithHours(hours) {
  let dropdown = document.getElementById("dropdown");
  hours.forEach((hour) => {
    let option = document.createElement("option");
    option.value = hour.id;
    option.textContent = `Broj sati: ${hour.hour}`;
    dropdown.appendChild(option);
  });
}

