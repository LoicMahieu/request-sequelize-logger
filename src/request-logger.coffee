
qs = require 'querystring'
Q = require 'q'
debug = require('debug')('request-logger')

now = -> (new Date()).getTime()

parseBody = (req) ->
  if req.body
    body = req.body.toString?() or req.body

    if req._json
      try
        body = JSON.parse(body)
      catch error
    else
      try
        body = qs.parse(body)
      catch error

    return body

parseResBody = (buffer, bodyLen, encoding) ->
  if buffer.length and Buffer.isBuffer(buffer[0])
    body = new Buffer(bodyLen)
    i = 0
    buffer.forEach (chunk) ->
      chunk.copy body, i, 0, chunk.length
      i += chunk.length

    return body.toString()
  else if buffer.length
    # The UTF8 BOM [0xEF,0xBB,0xBF] is converted to [0xFE,0xFF] in the JS UTC16/UCS2 representation.
    # Strip this value out when the encoding is set to 'utf8', as upstream consumers won't expect it and it breaks JSON.parse().
    buffer[0] = buffer[0].substring(1)  if self.encoding is 'utf8' and buffer[0].length > 0 and buffer[0][0] is '﻿\uFEFF'
    return buffer.join('')

module.exports =
(req, requestStart, requestEnd) ->
  [res, start, model, promise, bodyLen] = []
  buffer = []
  bodyLen = 0

  startLog = ->
    debug('Start log')

    defer = Q.defer()
    data =
      url: req.href
      method: req.method
      headers: req.headers
      querystring: qs.parse(req.uri.query)
      body: parseBody(req)
      start: new Date()

    start = now()

    requestStart data, (err) ->
      if err
        defer.reject err
      else
        defer.resolve model

    promise = defer.promise

  endLog = () ->
    debug('End log')

    largeBodyLimit = 40000

    body = parseResBody(buffer, bodyLen)

    try
      json = JSON.parse(body)
    catch error

    data =
      statusCode: res.statusCode
      resHeaders: res.headers or {}
      resJSON: json
      resBody: body?.substr?(0, largeBodyLimit)
      end: new Date()
      time: now() - start

    requestEnd(data)

  req.once 'request', ->
    startLog()

    req.once 'response', (_res) ->
      res = _res
      res.on 'data', (chunk) ->
        buffer.push(chunk)
        bodyLen += chunk.length

    req.once 'end', ->
      promise.done ->
        endLog()

  return req

