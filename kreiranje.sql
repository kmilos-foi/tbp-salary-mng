BEGIN;
CREATE TABLE titles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    salary_bonus INTEGER NOT NULL
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    title_id INTEGER REFERENCES titles(id),
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    employment_period DATERANGE
);

CREATE TABLE hours (
    id SERIAL PRIMARY KEY,
    hour INTEGER NOT NULL
);

CREATE TABLE work_times (
    hour_id INTEGER REFERENCES hours(id),
    employee_id INTEGER REFERENCES employees(id),
    day DATE NOT NULL,
    PRIMARY KEY (hour_id, employee_id, day)
);

CREATE TABLE log (
    id SERIAL PRIMARY KEY,
    message VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL
);

CREATE TABLE administrators (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL
);

CREATE TABLE payroll_processes (
    id SERIAL PRIMARY KEY,
    administrator_id INTEGER REFERENCES administrators(id),
    date DATE
);

CREATE TABLE payrolls (
    id SERIAL PRIMARY KEY,
    payroll_processes_id INTEGER REFERENCES payroll_processes(id),
    employee_id INTEGER REFERENCES employees(id),
    month_salary INTEGER NOT NULL,
    total_hours INTEGER NOT NULL
);

INSERT INTO titles (name, salary_bonus) VALUES
('menadzer', 1000),
('radnik', 50);

INSERT INTO employees (title_id, first_name, last_name, username, password, employment_period) VALUES
(1, 'Ivan', 'Ivić', 'user3', 'user', '[2020-01-01, 2023-12-31)'),
(2, 'Ana', 'Anić', 'user2', 'user', '[2021-05-15, 2025-05-15)'),
(2, 'Marko', 'Marić', 'user', 'user', '[2022-09-10, 2026-09-10)'),
(1, 'Boris', 'Borić', 'direktor', 'user', '[2023-09-10, 2026-09-10)');

INSERT INTO hours (hour) VALUES
(1), (2), (3), (4), (5), (6), (7), (8);


INSERT INTO administrators (first_name, last_name, username, password) VALUES
('Luka', 'Lukić', 'admin', 'admin'),
('Tina Tinić', 'Emić', 'eemic', 'admin456');

CREATE OR REPLACE FUNCTION check_employee_login(_username VARCHAR, _password VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    valid BOOLEAN;
BEGIN
    IF EXISTS (
        SELECT 1
        FROM employees
        WHERE username = _username 
          AND password = _password
          AND CURRENT_DATE >= lower(employment_period) 
          AND CURRENT_DATE < upper(employment_period)
    ) THEN
        valid := TRUE;
    ELSE
        valid := FALSE;
    END IF;

    RETURN valid;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_admin_login(_username VARCHAR, _password VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    valid BOOLEAN;
BEGIN
    IF EXISTS (
        SELECT 1
        FROM administrators
        WHERE username = _username AND password = _password
    ) THEN
        valid := TRUE;
    ELSE
        valid := FALSE;
    END IF;

    RETURN valid;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION set_log_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.timestamp IS NULL THEN
        NEW.timestamp := NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_log_timestamp
BEFORE INSERT ON log
FOR EACH ROW
EXECUTE PROCEDURE set_log_timestamp();


CREATE OR REPLACE FUNCTION validate_day()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.day > CURRENT_DATE THEN
        RAISE EXCEPTION 'Dan ne smije biti u budućnosti';
    END IF;

    IF NEW.day < CURRENT_DATE - INTERVAL '7 days' THEN
        RAISE EXCEPTION 'Dan ne smije biti stariji od tjedan dana';
    END IF;

    IF EXTRACT(MONTH FROM NEW.day) < EXTRACT(MONTH FROM CURRENT_DATE) AND
       EXTRACT(YEAR FROM NEW.day) <= EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'Dan ne smije biti iz prošlog mjeseca';
    END IF;
    
    IF EXTRACT(YEAR FROM NEW.day) < EXTRACT(YEAR FROM CURRENT_DATE) AND
       EXTRACT(MONTH FROM NEW.day) = 12 AND EXTRACT(MONTH FROM CURRENT_DATE) = 1 THEN
        RAISE EXCEPTION 'Dan ne smije biti iz prošlog mjeseca';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_day
BEFORE INSERT OR UPDATE ON work_times
FOR EACH ROW
EXECUTE FUNCTION validate_day();




CREATE OR REPLACE FUNCTION validate_payroll_month()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.date > CURRENT_DATE THEN
        RAISE EXCEPTION 'Obračun ne smije biti u budućnosti';
    END IF;

    IF NEW.date < CURRENT_DATE - INTERVAL '3 months' THEN
        RAISE EXCEPTION 'Obračin ne smije biti stariji od 3 mjeseca';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_payroll_month
BEFORE INSERT ON payroll_processes
FOR EACH ROW
EXECUTE FUNCTION validate_payroll_month();


CREATE OR REPLACE FUNCTION check_duplicate_workday()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM work_times
        WHERE employee_id = NEW.employee_id AND day = NEW.day
    ) THEN
        RAISE EXCEPTION 'Već ste unijeli sate za taj dan';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_duplicate_workday
BEFORE INSERT ON work_times
FOR EACH ROW
EXECUTE FUNCTION check_duplicate_workday();


CREATE OR REPLACE FUNCTION validate_employee_update()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.first_name = '' THEN
        RAISE EXCEPTION 'Ime ne smije biti prazno';
    END IF;

    IF NEW.last_name = '' THEN
        RAISE EXCEPTION 'Prezime ne smije biti prazno';
    END IF;

    IF NEW.username = '' THEN
        RAISE EXCEPTION 'Korisničko ime ne smije biti prazno';
    END IF;

    IF NEW.password = '' THEN
        RAISE EXCEPTION 'Lozinka ne smije biti prazna';
    END IF;

    IF NEW.title_id IS NULL THEN
        RAISE EXCEPTION 'Titula mora biti postavljena';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_before_update
BEFORE UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION validate_employee_update();

COMMIT;