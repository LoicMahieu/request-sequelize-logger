
Q = require 'q'
logger = require './request-logger'
traverse = require 'traverse'

module.exports =
(tableName, sequelize, options) ->
  Model = require('./model')(tableName, sequelize, sequelize.constructor)

  logError = (err) ->
    console.error err

  log = (req) ->
    model = null

    start = (data, cb) ->
      # In some versions of sequelize, all columns are inserted, so res(headers|json|body) can not be null
      data.resHeaders = {}
      data.resJSON = {}

      if (options.hideSensitive)
        hideDataFromKeys(data, options.keysToHide, options.hideValue)

      model = Model.build(data)

      return Q.when(model.save())
        .catch logError
        .then -> cb()

    end = (data) ->
      if (options.hideSensitive)
        hideDataFromKeys(data, options.keysToHide, options.hideValue)
      model.setAttributes data
      Q.when(model.save())
        .catch logError
        .then -> req.emit 'logger-end', model

    logger(req, start, end)

  log.Model = Model

  return log


hideDataFromKeys = (obj, keysToHide, hideValue) ->
  traverse(obj).forEach((data) ->
    if (~keysToHide.indexOf(@key))
      @update(hideValue)
  )
