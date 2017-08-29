process.env.NODE_ENV = 'dev'

const webpack = require('webpack')
const express = require('express')
const http = require('http')
const proxyMiddleware = require('http-proxy-middleware')
const devConfig = require('./webpack.dev.conf')
const { getUserConfig, resolve } = require('./utils')

const { dev } = getUserConfig()
const proxyTable = dev.proxyTable
const publicPath = devConfig.output.publicPath

module.exports = function startDev() {
  const app = express()
  const server = http.createServer(app)

  const compiler = webpack(devConfig, (err) => {
    if (err) throw err
  })

  const devMiddleware = require('webpack-dev-middleware')(compiler, {
    publicPath,
    quiet: true
  })

  const hotMiddleware = require('webpack-hot-middleware')(compiler, {
    log: () => {}
  })

  const uri = `http://localhost:${dev.port}${publicPath}`
  devMiddleware.waitUntilValid(() => console.log('> Listening at ' + uri + '\n'))

  Object.keys(proxyTable).forEach((context) => {
    let options = proxyTable[context]
    if (typeof options === 'string') {
      options = { target: options, changeOrigin: true }
    }
    app.use(proxyMiddleware(options.filter || context, options))
  })

  app.use(devMiddleware)
  app.use(hotMiddleware)
  app.use(publicPath, express.static(resolve('public')))

  server.listen(dev.port)
}
