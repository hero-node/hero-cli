# hero-cli

用来快速构建Hero App的命令行工具

* [快速开始](#快速开始) – 如何使用hero-cli工具快速创建一个Hero App
* [使用文档](#使用文档) – 如何使用hero-cli工具帮助开发一个Hero App

Hero App可以运行在Android, iOS和高级浏览器等环境中。如果发现任何issue，可以[点击这里](https://github.com/hero-mobile/hero-cli/issues/new)告诉我们。

## 如何构建Hero App

运行以下命令

```sh
npm install -g hero-mobile/hero-cli

hero init my-app
cd my-app/

npm install

```

当相关依赖安装完成后，在项目更目录下，可以运行以下命令：

* `npm start` 启动Hero App服务
* `npm run build` 将项目代码打包，生成一份优化后的代码，用于部署
* `npm run android` 生成一个Android APK格式的安装文件

成功运行`npm start`后，打开链接[http://localhost:3000/index.html](http://localhost:3000/index.html)可看到如下界面：

<img src='https://github.com/hero-mobile/hero-cli/blob/master/images/readme/start-homepage.png?raw=true' width='367' height='663' alt='npm start'>

hero-cli使用[Webpack](http://webpack.github.io/)来进行项目的打包，相应的配置隐藏在工具内部，让开放者更关注与业务逻辑的开发。

## 快速开始

### 安装

运行以下命令进行全局安装，安装后可以使用`hero`命令

```sh
npm install -g hero-mobile/hero-cli
```

**Node版本需要高于4.0，建议使用Node >= 6 和 npm >= 3**
你可以使用[nvm](https://github.com/creationix/nvm#usage)来安装，管理多个Node版本，并可以方便地在各个版本间进行切换。

### 创建Hero App

使用`hero init`命令来初始化一个Hero App

```sh
hero init my-app
cd my-app
```

该命令会在当前目录下创建一个`my-app`的目录并生成相应的项目代码，目录结构如下：

```
├── environments
│   ├── environment-dev.js
│   └── environment-prod.js
├── platforms
│   ├── android
│   └── iOS
├── public
│   ├── ...
│   └── favicon.ico
├── src
│   ├── ...
│   ├── index.html
│   └── index.js
├── .babelrc
├── .editorconfig
├── .eslintrc
├── .gitattributes
├── .gitignore
├── .hero-cli.json
├── package.json
└── README.md
```
在初始化的项目代码中, **以下文件或目录必须存在**:

* `platforms` 存放Android/iOS原生代码
* `src/index.html` 项目的HTML入口文件;
* `src/index.js` 项目的JavaScript入口文件.
* `.hero-cli.json` Hero App的配置文件。比如当用户运行`npm start`或`npm run build`（实际上在`package.json`中配置的调用的命令为`hero start -e dev` 和`hero build -e prod`）时，该加载哪些配置项。了解更多部署构建选项，点击查看[构建命令](#构建命令).

其他：
* `public` 该目录可以用来存放一个通用的资源，这些资源不会经过Webpack处理，而是直接复制到打包后的文件中
* `src` 该目录存放的文件会被Webpack处理，可以把JS,CSS等文件放在这个目录
* `environments` 存放不同环境的配置文件(该目录的路径可以在文件`.hero-cli.json`中配置)，该配置文件中的值可以通过全局变量访问到。具体方法见[添加环境变量](#添加环境变量).

你也许会发现HTML文件`pages/start.html`不存在，没错，该文件是生成出来的。详情见[动态生成HTML](#动态生成HTML)

## 使用文档

* [动态生成HTML](#动态生成HTML)
* [添加环境变量](#添加环境变量)
  * [JavaScript文件中引用环境变量](#JavaScript文件中引用环境变量)
  * [HTML文件中引用环境变量](#HTML文件中引用环境变量)
  * [Shell命令中添加环境变量](#Shell命令中添加环境变量)
  * [`.hero-cli.json`文件中添加环境变量](#hero-clijson文件中添加环境变量)
* [请求代理服务](#请求代理服务)
* [构建原生App安装包](#构建原生App安装包)
  * [Android](#android)
  * [iOS](#ios)
* [构建命令](#构建命令)
  * [`hero start`](#hero-start)
  * [`hero build`](#hero-build)
  * [`hero serve`](#hero-serve)
  * [`hero init`](#hero-init)
  * [`hero platform build android`](`#hero-platform-build-android)

### 动态生成HTML

在`src`目录中的JS文件，如果满足以下２个条件

* JS文件中存在`class`的类声明
* 声明的`class`类被来自[hero-cli/decorator](https://github.com/hero-mobile/hero-cli/blob/master/decorator.js)的[Decorator](https://github.com/wycats/javascript-decorators/blob/master/README.md) `@Entry`所修饰

则会经Webpack插件[html-webpack-plugin](https://www.npmjs.com/package/html-webpack-plugin)生成相应的HTML文件

* 可以通过`@Entry(options)`指定HTML文件生成的选项
* 默认情况下，该HTML文件生成后，访问的路径与当前JS的路径结构一致，你可以通过属性`path`来自定HTML访问的路径
* 生成的HTML文件也可以访问环境变量。如何添加环境变量？点击查看[添加环境变量](#添加环境变量)。

示例:<br>

文件`src/pages/start.js`将会生成一个对应的HTML文件，该HTML文件的访问路径为`/pages/start.html`, 同时该HTML文件包含了对`src/pages/start.js`的引用。

这就是为什么我们可以访问HTML[http://localhost:3000/pages/start.html](http://localhost:3000/pages/start.html).

```javascript
// 文件：
import { Entry } from 'hero-cli/decorator';

// 被@Entry所修饰的class，会生成一个对应的HTML文件
// 当前JS路径为: src/pages/start.js
// 所以生成的HTML访问路径为 /pages/start.html
//
// 代码＠Entry()
// 效果同
// @Entry({
//   path: '/pages/start.html'
// })
//
@Entry()
export class DecoratePage {

    sayHello(data){
      console.log('Hello Hero!')
    }

}

```

### 添加环境变量

项目代码可以访问机器上的环境变量。默认情况下，可以访问所有以`HERO_APP_`开头的变量，这样做的好处是，这些变量可以脱离版本管理工具如Git, SVN的控制。

**环境变量是在构建过程中添加进去的**.<br>

#### JavaScript文件中引用环境变量

在JavaScript文件中，可以通过全局变量`process.env`来访问环境变量，例如，当存在一个名为`HERO_APP_SECRET_CODE`的环境变量，则可以在JS中使用`process.env.HERO_APP_SECRET_CODE`来访问。

```javascript

console.log('Send Request with Token: '+ process.env.HERO_APP_SECRET_CODE);

```

同时，hero-cli会内置额外的２个环境变量`NODE_ENV`和`HOME_PAGE`到`process.env`中。

当运行`hero start`时，`NODE_ENV`的值为`'development'`；当运行`hero build`时，`NODE_ENV`的值为`'production'`；你不可以改变它的值，这是为了防止开发着误操作，将开发环境的包部署至生产。

使用`NODE_ENV`可以方便的执行某些操作：

例如：根据当前环境确定是否需要进行数据统计
```javascript

if (process.env.NODE_ENV !== 'production') {
  analytics.disable();
}

```

你可以访问`HOME_PAGE`，该变量的至为用户在`.hero-cli.json`中配置的`homepage`属性的值，它表示当前页面部署的URL路径。参考[构建路径配置](#构建路径配置).

#### HTML文件中引用环境变量

在HTML文件中，可以是用如下格式访问：

实例：当存在值为`Welcome Hero`的环境变量`HERO_APP_WEBSITE_NAME`，

```html
<title>%HERO_APP_WEBSITE_NAME%</title>

```
当用户访问该HTML文件时，标题`<title>`的值为`Welcome Hero`:

```html
<title>Welcome Hero</title>

```
#### Shell命令中添加环境变量

可以在Shell命令中添加环境变量，不同操作系统的声明方式不同。

##### Windows (cmd.exe)
```
set HERO_APP_SECRET_CODE=abcdef&&npm start

```

##### Linux, macOS (Bash)
```
HERO_APP_SECRET_CODE=abcdef npm start

```

#### `.hero-cli.json`文件中添加环境变量
Environment variables may varies from environments, such as `development`, `test` or `production`. <br>
You can specify the mapping info in the `.hero-cli.json` file, tell hero-cli loads the corresponding variables into environment variables.<br>

For example:

Here is the content of `.hero-cli.json`
```json
{
  "environments": {
    "dev": "src/environments/environment-dev.js",
    "prod": "src/environments/environment-prod.js"
  }
}

```
And here is the content of `src/environments/environment-prod.js`

```javascript
var environment = {
    backendURL: 'http://www.my-website.com/api'
};

module.exports = environment;

```

When you run command `hero start -e dev` or `hero build -e dev`, all variables from `src/environments/environment-dev.js` can be accessed via `process.env`.

### 请求代理服务
People often serve the front-end React app from the same host and port as their backend implementation.
For example, a production setup might look like this after the app is deployed:
```
/             - static server returns index.html with React app
/todos        - static server returns index.html with React app
/api/todos    - server handles any /api/* requests using the backend implementation

```

Such setup is not required. However, if you do have a setup like this, it is convenient to write requests like `fetch('/api/v2/todos')` without worrying about redirecting them to another host or port during development.

To tell the development server to proxy any unknown requests to your API server in development, add a proxy field to your `.hero-cli.json`, for example:

```json
{
  "proxy": {
    "/api/v2": "https://localhost:4000",
    "/feapi": "https://localhost:4001",
  },
  "environments": {
    "dev": "src/environments/environment-dev.js",
    "prod": "src/environments/environment-prod.js"
  }
}

```

This way, when you `fetch('/api/v2/todos')` in development, the development server will proxy your request to `http://localhost:4000/api/v2/todos`, and when you `fetch('/feapi/todos')`, the request will proxy to `https://localhost:4001`.

### 构建原生App安装包
#### Android
##### Prerequisites

* [Java](http://www.oracle.com/technetwork/java/javase/overview/index.html)
* [Android SDK](https://developer.android.com/)
* [Gradle](https://gradle.org/)

##### Configure your system environment variables

* `JAVA_HOME`
* `ANDROID_HOME`
* `GRADLE_HOME`

Currently, generated android apk will loads resources hosted by remote server. In order to make the appliation available in the your mobile.

Firstly, you have to deploy the codes generate by command [`hero build`](#hero-build) into remote server.<br>
Secondly, before you generate the apk, you should using parameter `-e` to tell the apk loads which url when it startup.

For example, you can config the url in file `.hero-cli.json` like this:

```json
{
  "android": {
    "prod": {
      "host": "http://www.my-site.com:3000/mkt/pages/start.html"
    }
  }
}
```
and then run below command to generate the android apk:

```sh
hero platform build android -e prod
```

Once project build successfully, android apk(s) will generated in folder `platforms/android/app/build/outputs/apk`.

For more options, see command of Build Scripts: [`Build Android App`](#build-android-app)

#### iOS


### 构建命令

#### `hero start`

Runs the app in development mode. And you can run `hero start -h` for help.<br>

This command has one mandatory parameter `-e`.
Usage: `hero start -e <env>`

The available `<env>` values come from keys configured in attribute `environments` in file `.hero-cli.json`.

hero-cli will load the corresponding configurations according to the `<env>` value by rules mentioned [above](#adding-development-environment-variables-via-hero-clijson).<br>

You can using `-p` specify the listen port start the application.<br>

```sh
hero start -e dev -p 3000
```
When start successfully, the page will reload if you make edits in folder `src`.<br>
You will see the build errors and lint warnings in the console.

<img src='https://github.com/hero-mobile/hero-cli/blob/master/images/readme/syntax-error-terminal.png?raw=true' width='600' alt='syntax error terminal'>

##### More Vaild options

* `-e`<br>Environment name of the configuration when start the application
* `-s`<br>Build the boundle as standalone version, which should run in Native App environment. That's to say, build version without libarary like [webcomponent polyfills](http://webcomponents.org/polyfills/) or [hero-js](https://github.com/hero-mobile/hero-js)(These libarary is necessary for Hero App run in web browser, not Native App).
* `-i`<br>Inline JavaScript code into HTML. Default value is [false].
* `-b`<br>Build pakcage only contain dependecies like hero-js or webcomponents, withou code in <you-project-path>/src folder. Default value is [false]
* `-m`<br>Build without sourcemap. Default value is [false], will generate sourcemap.
* `-f`<br>Generate AppCache file, default file name is "app.appcache". Default value is [false], will not generate this file.
* `-n`<br>Rename file without hashcode. Default value is [false], cause filename with hashcode.


#### `hero build`

Builds the app for production to the `build` folder. Options as same as `hero start` mentioned [above](#more-vaild-options), or you can run `hero build -h` for help<br>
The build is minified and the filenames include the hashes.<br>
It correctly bundles Hero App in production mode and optimizes the build for the best performance.

This command has one mandatory parameter `-e`.
Usage: `hero build -e <env>`

The available `<env>` values and configurations loading rules as same as [`hero start`](#hero start) .

##### 构建路径配置
By default, hero-cli produces a build assuming your app is hosted at the server root.
To override this, specify the value of attribute **homepage** in configuration `.hero-cli.json` file. Accept values see [Webpack#publicpath](http://webpack.github.io/docs/configuration.html#output-publicpath).

For example:

Here is the content of `.hero-cli.json`
```json
{
  "environments": {
    "dev": "src/environments/environment-dev.js",
    "prod": "src/environments/environment-prod.js"
  },
  "homepage": "/mkt/"
}

```
Then you can access the `start.html` by URL `/mkt/pages/start.html`

This will let Hero App correctly infer the root path to use in the generated HTML file.

#### `hero serve`
After `hero build` process completedly, `build` folder will generated. You can serve a static server using `hero serve`.

#### `hero init`
You can run `hero build -h` for help. It will generate the initial project structure of Hero App. See [Creating an App](#creating-an-app).

#### `hero platform build`
This command used for build native app. And you can run `hero platform build -h` for help.<br>
##### Build Android App

`hero platform build android`

It has one mandatory parameter `-e <env>`.
The available `env` values from properties of attribute `android` in file `.hero-cli.json`.

For example:

Here is the content of `.hero-cli.json`
```json
{
  "android": {
    "dev": {
      "host": "http://10.0.2.2:3000/mkt/pages/start.html"
    },
    "prod": {
      "host": "http://www.my-site.com:3000/mkt/pages/start.html"
    }
  }
}

```
The available `env` values are `dev` and `prod`.

Once command `hero platform build android -e prod` execute successfully, a android apk will generated, when you install and open the app in your mobile, `http://www.my-site.com:3000/mkt/pages/start.html` will be the entry page.

###### How to specify the android build tool version in SDK
Hero will dynamic using the lastest available one from your local install versions by default.
You might have multiple available versions in the Android SDK. You can specify the `ANDROID_HOME/build-toos` version and compile `com.android.support:appcompat-v7` version following the keyword `android` and seperated by colon.

For example, you can using the below command specify the `ANDROID_HOME/build-toos` version `23.0.2` and compile `com.android.support:appcompat-v7` version `24.0.0-alpha1`:

```sh
hero platform build android:23.0.2:24.0.0-alpha1 -e prod
```

or just specify the `ANDROID_HOME/build-toos` version only:

```sh
hero platform build android:23.0.2 -e prod
```
