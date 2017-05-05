该包可以独立运行

# 安装NPM依赖
`npm install`

# 启动服务
`npm start`

启动成功后
1. 会启动Mock Server,动态加载modules目录下面的路由文件，可在package.json中配置`serverConfig.mockAPIPrefix`，为所有的URL增加前缀。
2. 会启动Proxy服务，为package.json中配置`serverConfig.mockAPIPrefix`中的每个URL启动一个Proxy服务，每个URL的Proxy端口号会基于`serverConfig.proxyBasePort`自增长。
