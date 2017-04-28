This package can run independently as mock server during development.

## How to start

```
npm install
npm start

```
Once start successfully, you can see below messages:

```
Proxy server is running at:
http://localhost:3000 will proxy to http://www.my-website.com

Mock server is running at:
http://localhost:3001

```

It will start proxy server and mock server at different port:

* Start the mock serer and dynamic loads URL routers in folder `modules`.
* Start the proxy server, the proxy target configured in attribute serverConfig of file `package.json`.

```javascript
"serverConfig": {
  // the prefix of mock server API routers url
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
