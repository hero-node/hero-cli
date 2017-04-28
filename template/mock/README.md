该包可以独立运行

# 安装NPM依赖
`npm install`

# 启动服务
`npm start`

启动成功后
1. 会启动Mock Server,动态加载modules目录下面的路由文件，可在package.json中配置`serverConfig.mockAPIPrefix`，为所有的URL增加前缀。
2. 会启动Proxy服务，为package.json中配置`serverConfig.mockAPIPrefix`中的每个URL启动一个Proxy服务，每个URL的Proxy端口号会基于`serverConfig.proxyBasePort`自增长。

#### `npm run mock`

* Start the mock serer using the codes in folder [mock/](https://github.com/hero-mobile/hero-cli/tree/master/template/mock)
* Start the proxy server, the proxy target in configuration file [mock/package.json#serverConfig](https://github.com/hero-mobile/hero-cli/blob/master/template/mock/package.json)

```javascript

"serverConfig": {
  // the prefix of mock server url
  "mockAPIPrefix": "",
  // the initial port used by proxy/mock server
  "proxyBasePort": 3000,
  // start an instance of proxy server for every url in #proxyTargetURLs
  // the port number increment by step 1
  "proxyTargetURLs": [
    "http://www.my-website.com"
  ]
}

```

Once start successfully, you can see below messages:

```
Proxy server is running at:
http://localhost:3000 will proxy to http://www.my-website.com


Mock server is running at:
http://localhost:3001
```
