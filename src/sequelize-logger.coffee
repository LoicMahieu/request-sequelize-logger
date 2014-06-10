
qs = require 'querystring'
Q = require 'q'
logger = require './request-logger'

module.exports =
(tableName, sequelize, options) ->
  Model = require('./model')(tableName, sequelize, sequelize.constructor)

  return (req) ->
    model = null

    start = (data, cb) ->
      # In some versions of sequelize, all columns are inserted, so res(headers|json|body) can not be null
      data.resHeaders = '{}'
      data.resJSON = '{}'
      data.resBody = '{}'

      model = Model.build(data)
      model.save().done cb

    end = (data) ->
      model.setAttributes data
      model.save()

    logger(req, start, end)
