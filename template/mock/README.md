This mock server will forward all the requests to the target server.

## How to start
Run command:

```sh
npm install
npm start

```

Once start successfully, server will running at port **4000**, forward all the received request to the **https://www.my-site.com**.

You can edit the attribute `proxyPort` and `proxyTarget` in `package.json` to change the server running port and proxy target.
