
path = require 'path'
fs = require 'fs'
request = require 'request'

requireTest = (path) ->
  require((process.env.APP_SRV_COVERAGE || '../') + path)

requireLogger = -> requireTest('lib/request-logger')


chai = require 'chai'
assert = chai.assert
expect = chai.expect
chai.should()

describe 'request-logger', ->
  it 'is a function', ->
    expect(requireLogger()).to.be.a('function')

  it 'works', (done) ->
    req = request.get('http://httpbin.org/get', { qs: { args: 1 } })
    logger = requireLogger()

    start = (data, cb) ->
      expect(data).to.be.a('object')
      expect(data.url).to.equal('http://httpbin.org/get?args=1')
      expect(data.method).to.equal('GET')
      expect(data.headers).to.deep.equal({
        host: 'httpbin.org'
      })
      expect(data.body).to.equal()
      expect(data.start).to.a('date')

      cb()

    end = (data) ->
      expect(data).to.be.a('object')
      expect(data.statusCode).to.equal(200)
      expect(data.resHeaders).to.be.a('object')
      expect(data.resJSON).to.be.a('object')
      expect(data.resBody).to.be.a('string')
      expect(data.time).to.a('number')
      expect(data.end).to.a('date')

      done()

    logger(req, start, end)
