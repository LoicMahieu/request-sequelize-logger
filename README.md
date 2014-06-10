request-sequelize-logger
========================

Log requests made with [https://github.com/mikeal/request](request) in a [https://github.com/sequelize/sequelize](Sequelize) model.

Usage:

```js
var request = require('request');
var Sequelize = require('sequelize');
var SequelizeLogger = require('request-sequelize-logger');

var sequelize = new Sequelize('test', 'root', '', {
  logging: console.log
});

var logger = SequelizeLogger('test_logger', sequelize);

sequelize.sync({force: true}).done(function (err) {

  logger(request.post('http://google.com/?some_qs=true', { form: {test: true} }));
  logger(request.post('http://httpbin.org/post', { form: {test: true} }));
  logger(request.get('http://httpbin.org/get', { qs: {test: true} }));
  logger(request.head('http://httpbin.org/get', { qs: {test: true} }));

});
```
