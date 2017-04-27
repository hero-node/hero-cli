# Hero-cli

Create Hero apps with no build configuration.

* [Getting Started](#getting-started) – How to create a new app.
* [User Guide](https://github.com/hero-mobile/docs/hero-cli) – How to develop apps bootstrapped with Hero App.

Hero App works on Android, iOS, and Modem browser.<br>
If something doesn’t work please [file an issue](https://github.com/hero-mobile/hero-cli/issues/new).

## Quick Overview

```sh
npm install -g hero-mobile/hero-cli

hero init my-app
cd my-app/
npm install
npm start
```

Then open [http://localhost:4000/?state=http://localhost:4000/entry/login.html](http://localhost:4000/?state=http://localhost:4000/entry/login.html) to see your app.<br>
You can start the mock server during the development with command `npm run mock`.<br>
When you’re ready to deploy to production, create a minified bundle with `npm run build`. For more build options please refer to [Build Options](https://hero-mobile.github.io/docs/build-options)

<img src='https://github.com/hero-mobile/hero-cli/blob/master/images/readme/hero-start.png?raw=true' width='600' alt='npm start'>

### Get Started Immediately

You **don’t** need to install or configure tools like Webpack or Babel.<br>
They are preconfigured and hidden so that you can focus on the code.

Just create a project, and you’re good to go.

## Getting Started


### Installation

Install it once globally:

```sh
npm install -g hero-mobile/hero-cli
```

**You’ll need to have Node >= 4 on your machine**.

**We strongly recommend to use Node >= 6 and npm >= 3 for faster installation speed and better disk usage.** You can use [nvm](https://github.com/creationix/nvm#usage) to easily switch Node versions between different projects.

### Creating an App

To create a new app, run:

```sh
hero init my-app
cd my-app
```

It will create a directory called `my-app` inside the current folder.<br>
Inside that directory, it will generate the initial project structure and then you can run command `npm install` to install the dependencies manually:

```
├── mock/
│   └── ...
├── public
│   ├── ...
│   └── favicon.ico
├── src
│   ├── ...
│   ├── environments/
│   ├── index.html
│   └── index.js
├── .editorconfig
├── .gitattributes
├── .gitignore
├── .hero-cli.json
├── package.json
└── README.md
```
For the project to build, **these files must exist with exact filenames**:

* `src/index.html` is the entry page;
* `src/index.js` is the JavaScript entry point.
* `.hero-cli.json` is the configuration file for hero-cli build


During the development:

* You may create subdirectories inside `src`. For faster rebuilds, only files inside `src` are processed by Webpack. You need to **put any JS and CSS files inside `src`**, or Webpack won’t see them.
* You may add your mock data inside `mock`.
* You can put your assets like images into `public`,  it will not be processed by Webpack. Instead it will be copied into the build folder untouched.
* You can put configurations into `src/environments`(This folder name is configured in file `.hero-cli.json`, you can change it later), In JavaScript or HTML code, you can use it as describled below.

```javascript
// example content of .hero-cli.json
{
  "environments": {
    "dev": "src/environments/environment-dev.js",
    "prod": "src/environments/environment-prod.js"
  }
}

```

* Any JS file Using [Decorator](https://github.com/wycats/javascript-decorators/blob/master/README.md) `@Entry()` onto certain JavaScript `class` or `function`, this file will treated as entry file, during the development or build process, a HTML file would generated using [html-webpack-plugin](https://www.npmjs.com/package/html-webpack-plugin) plugin, options specified as first argument in `@Entry()` will passed to Webpack plugin html-webpack-plugin transparently.

```javascript
import { Component, Boot, Message } from 'hero-js';
import { Entry } from 'hero-cli/decorator';

var defaultUIViews = {

}

@Entry()
@Component({
  view: defaultUIViews
})
export class DecoratePage {

    @Boot
    before(data){
      console.log('Bootstrap successfully!')
    }

    @Message('__data.click && __data.click == "login"')
    login(data) {
      console.log('Send Login Request...')
    }
}

```

Once the installation is done, you can run some commands inside the project folder:

#### `npm start`

Runs the app in development mode.<br>
Open [http://localhost:4000/?state=http://localhost:4000/entry/login.html](http://localhost:4000/?state=http://localhost:4000/entry/login.html) to view it in the browser.

This command invoke `hero start -e <env>` underneath. You can run `hero start -h` for help<br>
The available `<env>` values come from keys configured in attribute `environments` in file `.hero-cli.json`.<br>
And then, hero-cli will load the corresponding configurations under folder `src/environments` according to the `<env>` value.<br>When start successfully, you can access those configurations via `process.env`.

In JavaScript code, you can use `process.env` to access it like this:

```javascript
console.log(process.env['My-Attribute-Key']);
```

Inside index.html, you can use it for similar purposes:

```html
<base href="%My-Attribute-Key%"/>
<link rel="shortcut icon" href="%My-Attribute-Key%/favicon.ico">
```

The page will reload if you make edits in folder `src`.<br>
You will see the build errors and lint warnings in the console.

<img src='https://github.com/hero-mobile/hero-cli/blob/master/images/readme/syntax-error-terminal.png?raw=true' width='600' alt='syntax error terminal'>

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

#### `npm run build`

Builds the app for production to the `build` folder.<br>
The build is minified and the filenames include the hashes.<br>
It correctly bundles Hero App in production mode and optimizes the build for the best performance.

This command invoke `hero build -e <env>` underneath, The available `<env>` value as same as [npm start](#npm-start). And you can run `hero build -h` for more options as below.<br>

* -s<br>Build this project to standalone version, which to run in Native App environment. That's to say, build version without libarary like [webcomponent polyfills](https://www.polymer-project.org/) or [hero-js](https://github.com/hero-mobile/hero-js) which is necessary when Hero App run in web browser.

* -m<br>Build this project without sourcemap

##### Building for Relative Paths
By default, Hero-cli produces a build assuming your app is hosted at the server root.
To override this, specify the value([Valid Values see Webpack#publicPath](http://webpack.github.io/docs/configuration.html#output-publicpath)) of key `__homepage`(This name is preserved for this purpose) in your configuration file in `src/environments`.

for example:

```

var environment = {
    __homepage: 'http://mywebsite.com/relativepath'
};

module.exports = environment;

```
This will let Hero App correctly infer the root path to use in the generated HTML file.
