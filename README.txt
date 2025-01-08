NAPOMENA - Aplikacija je testirana na Chrome/Chromium preglednicima i na njima bi se aplikacija trebala pokretati.
Ostali preglednici potencijalno nemaju podržane neke UI elemente (npr. Firefox nema UI element za odabir mjeseca i godine)

Koraci za pokretanje servera:
    1. Potrebno je otvoriti projekt i upisati naredbu npm run prepare za instalaciju svih npm paketa
    2. Ako npm run prepare slučajno ne istalira sve pakete, može se pokušati "npm install" ili pojedinačno instalirati pakete "npm install ime-paketa"
    2. cd src
    3. nodemon server.js
    4. server je pokrenut na localhost:12000
    5. za prijavu se koristi user/user i admin/admin (ovisno u ulozi, no prije toga je potrebno postaviti BP)

Koraci za uspostavljanje baze podataka
    1. Potrebno je kreirati bazu podataka salary_mng
    2. Potrebno je pokrenuti skriptu kreiranje.sql koja se nalazi u projektu (\i kreiranje.sql)
    3. Kada je baza kreirana, potrebno je otići u src/db/db.js i upisati vlastite podatke