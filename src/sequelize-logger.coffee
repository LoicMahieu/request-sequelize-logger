
qs = require 'querystring'
Q = require 'q'
logger = require './request-logger'

module.exports =
(tableName, sequelize, options) ->
  Model = require('./model')(tableName, sequelize, sequelize.constructor)

  log = (req) ->
    model = null

    start = (data, cb) ->
      # In some versions of sequelize, all columns are inserted, so res(headers|json|body) can not be null
      data.resHeaders = {}
      data.resJSON = {}

      model = Model.build(data)
      Q.when(model.save())
        .nodeify cb

    end = (data) ->
      model.setAttributes data
      model.save().then ->
        req.emit 'logger-end', model

    logger(req, start, end)

  log.Model = Model

  return log
