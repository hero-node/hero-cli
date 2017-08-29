const publicPath = '/'

module.exports = {
  router: require('./router'), // map for rename fileName
  build: {
    publicPath, // assets publicPath for webpack.output.publicPath, should end by /
    env: require('./environments/environment-prod') // env fro webpack.DefinePlugin, process.env.xx
  },
  dev: {
    publicPath,
    env: require('./environments/environment-dev'),
    port: 3000, // dev server listen port
    proxyTable: { // proxyMiddleware
      '/api/v2': 'https://yourDomain'
    }
  }
}
