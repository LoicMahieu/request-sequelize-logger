
Q = require 'q'
traverse = require 'traverse'
cloneDeep = require 'lodash.clonedeep'
logger = require './request-logger'

module.exports =
(tableName, sequelize, options) ->
  Model = require('./model')(tableName, sequelize, sequelize.constructor)
  options = Object.assign(
    hideKeys: []
    hideValue: '******'
  , options)

  logError = (err) ->
    console.error err

  log = (req) ->
    model = null

    start = (data, cb) ->
      # In some versions of sequelize, all columns are inserted, so res(headers|json|body) can not be null
      data.resHeaders = {}
      data.resJSON = {}

      if (options.hideKeys.length > 0)
        data = hideDataFromKeys(data, options.hideKeys, options.hideValue)

      model = Model.build(data)

      return Q.when(model.save())
        .catch logError
        .then -> cb()

    end = (data) ->
      if (options.hideKeys.length > 0)
        data = hideDataFromKeys(data, options.hideKeys, options.hideValue)
      model.setAttributes data
      Q.when(model.save())
        .catch logError
        .then -> req.emit 'logger-end', model

    logger(req, start, end)

  log.Model = Model

  return log


hideDataFromKeys = (obj, hideKeys, hideValue) ->
  obj = cloneDeep(obj)

  traverse(obj).forEach((data) ->
    if (~hideKeys.indexOf(@key))
      @update(hideValue)
  )
