const { Pool, types } = require('pg');

const pool = new Pool({
    user: '',
    host: 'localhost',
    database: 'salary_mng',
    password: '',
    port: 5432,
});

types.setTypeParser(1082, (val) => val);

module.exports = pool;