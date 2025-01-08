let txtUsername = document.getElementById("txtUsername");
let txtPassword = document.getElementById("txtPassword");
let lblError = document.getElementById("lblError");

window.addEventListener("DOMContentLoaded", () => {
  setLoginButton();
});

function setLoginButton() {
  btnLogin.addEventListener("click", handleLoginButtonClick);
}

function handleLoginButtonClick(event) {
  event.preventDefault();
  isFormValid() ? login() : loginForm.reportValidity();
}

function isFormValid() {
  return loginForm.checkValidity();
}

async function login() {
  let options = setOptions();
  let cboIsEmployee = document.getElementById("cboIsEmployee");
  let response;
  if(cboIsEmployee.checked) {
    response = await fetch("/employee-login", options);
    response.ok ? handleLoginSuccess("employee") : handleLoginFailure(response);
  } else {
    response = await fetch("/admin-login", options);
    response.ok ? handleLoginSuccess("admin") : handleLoginFailure(response);
  }
}

function setOptions() {
  return {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(setBody()),
  };
}

function setBody() {
  let body = {
    username: txtUsername.value,
    password: txtPassword.value,
  };
  return body;
}

function handleLoginSuccess(role) {
  lblError.style.visibility = "hidden";
  resetInput();
  if (role == "admin") {
    window.location.href = "/index-admin";
  } else {
    window.location.href = "/index-employee";
  }
}

function handleLoginFailure(response) {
  let lblError = document.getElementById("lblError");
  lblError.innerText = "Prijava neuspješna!"
  lblError.style.visibility = "visible";
  resetInput();
}

function resetInput() {
  txtUsername.value = "";
  txtPassword.value = "";
}
