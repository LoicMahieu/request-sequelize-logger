
_ = require('lodash')

propJSON = (prop, options) ->
  _.extend
    # works only with mysql because postgres does handle longtext
    type: 'LONGTEXT'
    allowNull: false
    get: getterJSONValue prop, options
    set: setterJSONValue prop, options
  , options

setterJSONValue = (prop, options) ->
  setter = options?.set
  delete options?.set

  ((value) ->
    if typeof value != 'string'
      if setter
        value = setter.call @, value

      unless _.isUndefined(value)
        value = JSON.stringify value, null, 2

    @setDataValue prop, value
  )

getterJSONValue = (prop, options) ->
  origin = null
  deserialized = null
  getter = options?.get
  delete options?.get

  (() ->
    value = @getDataValue prop

    if origin != value
      origin = value

      unless _.isUndefined(value)
        deserialized = JSON.parse value

      if getter
        deserialized = getter.call @, deserialized

    return deserialized
  )

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

    headers: propJSON('headers', validate: notNullEmpty)
    querystring: propJSON('querystring', validate: notNullEmpty)
    body: propJSON('body')

    # Respond
    end: type: DataTypes.DATE
    time: type: DataTypes.INTEGER
    statusCode: type: DataTypes.STRING(20)
    resHeaders: propJSON('resHeaders')
    resJSON: propJSON('resJSON')
    resBody: propJSON('resBody')
