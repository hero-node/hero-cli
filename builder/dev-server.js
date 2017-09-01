process.env.NODE_ENV = 'dev'

const webpack = require('webpack')
const express = require('express')
const http = require('http')
const proxyMiddleware = require('http-proxy-middleware')
const chalk = require('chalk')

const devConfig = require('./webpack.dev.conf')
const { getUserConfig, resolve } = require('./utils')

const { dev } = getUserConfig()
const proxyTable = dev.proxyTable
const publicPath = devConfig.output.publicPath

function serve() {
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
    log: false
  })

  Object.keys(proxyTable).forEach((context) => {
    let options = proxyTable[context]
    if (typeof options === 'string') {
      options = { target: options, changeOrigin: true }
    }
    app.use(proxyMiddleware(options.filter || context, options))
  })

  compiler.plugin('compilation', (compilation) => {
    compilation.plugin('html-webpack-plugin-after-emit', (data, cb) => {
      hotMiddleware.publish({ action: 'reload' })
      cb()
    })
  })

  app.use(devMiddleware)
  app.use(hotMiddleware)
  app.use(publicPath, express.static(resolve('public')))

  const uri = `http://localhost:${dev.port}${publicPath}`
  console.log(chalk.green('> Starting dev server...'))
  server.listen(dev.port)
  devMiddleware.waitUntilValid(
    // force compile to fix '__webpack_require__ ... is not a function'
    () => compiler.run(
      () => console.log('> Listening at ' + uri + '\n')
    )
  )
}

module.exports = serve
