module.exports = {
  database: {
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: '123456',
    database: 'coffee'
  },
  server: {
    port: process.env.PORT || 3000
  }
};
