
path = require 'path'
fs = require 'fs'
request = require 'request'
connect = require 'connect'
serveStatic = require 'serve-static'

requireTest = (path) ->
  require((process.env.APP_SRV_COVERAGE || '../') + path)

requireLogger = -> requireTest('lib/sequelize-logger')


Sequelize = require 'sequelize'
sequelize = new Sequelize('test', 'root', '', {
  logging: false
})

chai = require 'chai'
assert = chai.assert
expect = chai.expect
chai.should()

fixturesDir = path.join __dirname, '..', 'test/fixtures'

describe 'sequelize-logger', ->
  logger = null

  before (done) ->
    logger = requireLogger()('test_sequelize_logger', sequelize, Sequelize)
    sequelize.sync(force: true).nodeify done

  before (done) ->
    server = connect()
    server.use(serveStatic(fixturesDir))
    server.listen(4000, done)

  it 'is a function', ->
    expect(requireLogger()).to.be.a('function')

  it 'Simple GET', (done) ->
    req = request.get('http://httpbin.org/get', { qs: { args: 1 } })
    logger(req)

    req.once 'logger-end', (model) ->
      expect(model.url).to.equal('http://httpbin.org/get?args=1')
      expect(model.method).to.equal('GET')
      expect(model.headers).to.deep.equal({
        host: 'httpbin.org'
      })
      expect(model.body).to.equal(undefined)
      expect(model.start).to.a('date')

      expect(model.statusCode).to.equal(200)
      expect(model.resHeaders).to.be.a('object')
      expect(model.resJSON).to.be.a('object')
      expect(model.resBody).to.be.a('string')
      expect(model.time).to.a('number')
      expect(model.end).to.a('date')

      done()

  it 'Simple POST with JSON', (done) ->
    req = request.post 'http://httpbin.org/post',
      json:
        some: data: 1
    logger(req)

    req.once 'logger-end', (model) ->
      expect(model.url).to.equal('http://httpbin.org/post')
      expect(model.method).to.equal('POST')
      expect(model.headers).to.deep.equal({
        accept: 'application/json'
        'content-length': 19
        'content-type': 'application/json'
        host: 'httpbin.org'
      })
      expect(model.body).to.deep.equal(
        some: data: 1
      )
      expect(model.start).to.a('date')

      expect(model.statusCode).to.equal(200)
      expect(model.resHeaders).to.be.a('object')
      expect(model.resJSON).to.be.a('object')
      expect(model.resBody).to.be.a('string')
      expect(model.time).to.a('number')
      expect(model.end).to.a('date')

      done()

  it 'Simple GET with big JSON', (done) ->
    req = request.get 'http://localhost:4000/some-big.json'
    logger(req)

    req.once 'logger-end', (model) ->
      expect(model.url).to.equal('http://localhost:4000/some-big.json')
      expect(model.method).to.equal('GET')
      expect(model.headers).to.deep.equal({
        host: 'localhost:4000'
      })
      expect(model.body).to.equal(undefined)
      expect(model.start).to.a('date')

      expect(model.statusCode).to.equal(200)
      expect(model.resHeaders).to.be.a('object')
      expect(model.resJSON).to.be.a('object')
      expect(model.resBody).to.be.a('string')
      expect(model.time).to.a('number')
      expect(model.end).to.a('date')

      done()
