
_ = require 'lodash'
json = require('sequelize-utils').property.json

module.exports = (tableName, sequelize, DataTypes) ->
  Model = sequelize.define tableName,
    # Request
    start:
      type: DataTypes.DATE
      allowNull: false

    url:
      type: DataTypes.STRING(500)
      allowNull: false
      validate: notEmpty: true

    method:
      type: DataTypes.STRING(10)
      allowNull: false
      validate: notEmpty: true

    headers: json('headers', validate: notEmpty: true)
    querystring: json('querystring', validate: notEmpty: true)
    body: json('body')

    # Respond
    end: type: DataTypes.DATE
    time: type: DataTypes.INTEGER
    statusCode: type: DataTypes.STRING(20)
    resHeaders: json('resHeaders')
    resJSON: json('resJSON')
    resBody: json('resBody')
