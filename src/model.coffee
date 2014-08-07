
_ = require 'lodash'
json = require('sequelize-utils').property.json

module.exports = (tableName, sequelize, DataTypes) ->
  notNullEmpty =
    notNull: true
    notEmpty: true

  Model = sequelize.define tableName,
    # Request
    start:
      type: DataTypes.DATE
      validate:
        notNull: true

    url:
      type: DataTypes.STRING(500)
      validate: notNullEmpty

    method:
      type: DataTypes.STRING(10)
      validate: notNullEmpty

    headers: json('headers', validate: notNullEmpty)
    querystring: json('querystring', validate: notNullEmpty)
    body: json('body')

    # Respond
    end: type: DataTypes.DATE
    time: type: DataTypes.INTEGER
    statusCode: type: DataTypes.STRING(20)
    resHeaders: json('resHeaders')
    resJSON: json('resJSON')
    resBody: json('resBody')
