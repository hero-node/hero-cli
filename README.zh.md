# hero-cli

[Documetation for English](https://github.com/hero-mobile/hero-cli)

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
部署阶段，环境变量会随着部署环境的不同而不同，如开发环境, 测试环境和生产环境等。你可以通过在文件`.hero-cli.json`中指定相应环境及环境变量的对应关系。

示例：

以下是文件`.hero-cli.json`的内容，指定了`dev`和`prod`环境及环境变量的对应关系
```json
{
  "environments": {
    "dev": "src/environments/environment-dev.js",
    "prod": "src/environments/environment-prod.js"
  }
}

```
以下是文件`src/environments/environment-prod.js`的内容

```javascript
var environment = {
    backendURL: 'http://www.my-website.com/api'
};

module.exports = environment;

```
当运行命令`hero start -e dev`或`hero build -e dev`时，文件`src/environments/environment-dev.js`中定义的变量在JavaScript中可以通过`process.env`访问。

### 请求代理服务
项目部署阶段，运维人员经常会把前后端部署在同一域名和端口下，从而避免跨域问题。

例如，项目部署后，前后的的访问情况如下：

```
/             - 可以访问前端的静态资源，如index.html
/api/todos    - URL匹配/api/*的请求，能访问后端的服务API接口

```
这样的线上配置并不是必须的，不过这样配置后，可以使用类似`fetch('/api/v2/todos')`的代码来发起后端服务请求。

然而在开发过程中，前端服务与后端服务通常在不同的端口，会出现跨域的问题。为了解决该问题，可以透明地将请求转发至相应的后端服务，从而解决跨域问题。

可以通过配置文件`.hero-cli.json`，实现请求代理服务。

实例：以下是文件`.hero-cli.json`内容
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
这样配置之后，当代码`fetch('/api/v2/todos')`发送请求时，该请求会被转发至`https://localhost:4000/api/v2/todos`；当代码`fetch('/feapi/todos')`发送请求时，该请求会被转发至`https://localhost:4001/feapi/todos`.

### 构建原生App安装包
#### Android
##### Prerequisites

* [Java](http://www.oracle.com/technetwork/java/javase/overview/index.html)
* [Android SDK](https://developer.android.com/)
* [Gradle](https://gradle.org/)

##### 配置环境变量

* `JAVA_HOME`
* `ANDROID_HOME`
* `GRADLE_HOME`

当安装使用该工具生成后的App，在启动时会加载一个入口文件，该入口文件包含相应的业务逻辑代码。

因此，在生成该App的安装包时，需要进行以下步骤：

* 使用[`hero build`](#hero-build)命令将业务逻辑代码打包部署
* 在文件`.hero-cli.json`中指定一个HTML入口地址
* 使用[`hero platform build`](#hero- platform-build)命令生成App安装包，同时需使用`-e`参数指定使用哪个配置文件

示例：　

以下是文件`.hero-cli.json`的内容
```json
{
  "android": {
    "prod": {
      "host": "http://www.my-site.com:3000/mkt/pages/start.html"
    }
  }
}
```
接着运行以下命令便可生成Android APK安装文件：

```sh
hero platform build android -e prod
```

该APK文件生成的路径为： `platforms/android/app/build/outputs/apk`.

查看更多信息，点击查看[构建Android APK安装包](#构建android-apk安装包)

#### iOS


### 构建命令

#### `hero start`
该命令会启动开发环境的模式，你可以运行`hero start -h`查看帮助。
该命令需要一个`-e`参数，指定启动时的配置文件。用法为: `hero start -e <env>`。

`-e`参数的值是根据文件`.hero-cli.json`中属性`environments`来确定的。用法在[这里](#hero-clijson文件中添加环境变量)有说明

同时，可以使用`-p`参数指定服务启动的端口。

```sh
hero start -e dev -p 3000
```
启动成功后，队友`src`目录中的改动，代码都会重新编译并且浏览器会重新刷新页面，对有JavaScript代码的ESLint结果会显示在浏览器的控制台中。
<img src='https://github.com/hero-mobile/hero-cli/blob/master/images/readme/syntax-error-terminal.png?raw=true' width='600' alt='syntax error terminal'>

##### 更多选项

* `-e`<br>指定在启动时加载的配置环境的名称
* `-s`<br>指定打包后的文件中只包含业务逻辑代码，不包括[webcomponent polyfills](http://webcomponents.org/polyfills/) 和[hero-js](https://github.com/hero-mobile/hero-js)等组件库。
* `-i`<br>指定将JavaScript和CSS内联至HTML文件中。
* `-b`<br>指定打包后的文件中只包含[webcomponent polyfills](http://webcomponents.org/polyfills/) 和[hero-js](https://github.com/hero-mobile/hero-js)等组件库。
* `-m`<br>不生成sourcemap文件。默认生成sourcemap文件。
* `-f`<br>指定生成AppCache文件，默认的文件名称为"app.appcache"。默认情况下不生成该文件。
* `-n`<br>指定文件名保留原始名称，不添加hash值。默认是添加hash值。

#### `hero build`
使用该命令可以对项目进行打包构建，该命令也需要指定一个必需的参数`-e`，相关的参数同`hero start`。
你可以运行`hero build -h`查看帮助。

##### 构建路径配置
默认情况下，hero-cli会认为该项目打包构建后生成的文件，在这些文件中，互相引用的路径为绝对路径，并且部署在域名的根路径之下。
当需要修改该情况，可以通过修改文件`.hero-cli.json`中属性　**homepage** 的值。

示例：

以下是文件`.hero-cli.json`的内容
```json
{
  "environments": {
    "dev": "src/environments/environment-dev.js",
    "prod": "src/environments/environment-prod.js"
  },
  "homepage": "/mkt/"
}

```
这样配置之后，资源在访问是需要加上前缀`/mkt`,比如原先的`/start.html`路径变为`/mkt/pages/start.html`。

#### `hero serve`
打使用`hero build`命令打包完成后，在部署之前，可以使用该命令预览构建后的代码运行后的效果。

#### `hero init`
使用该命令可以初始化一个Hero App项目工程。示例用法见[如何构建Hero App](#如何构建hero-app).

#### `hero platform build`
This command used for build native app. And you can run `hero platform build -h` for help.<br>
##### 构建Android APK安装包

`hero platform build android`

该命令需要指定一个必需的参数`-e <env>`，其中`<env>`的取值根据文件`.hero-cli.json`中属性`android`来确定。

示例：
以下是文件`.hero-cli.json`的内容
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
那么可选的`env`参数则有`dev`和`prod`。

当安装并打开该Native App时，启动时则会加载页面http://www.my-site.com:3000/mkt/pages/start.html。

###### How to specify the android build tool version in SDK
hero-cli会自动检测当前开发者环境已安装的Android build tool的所有可用版本，并会默认使用最新的版本。
当然，你也可以手动的指定在打包时需要使用的各个版本。方法是在命令`hero platform build android`中指定各个版本，不同工具的版本使用分号分割。

示例：

指定`ANDROID_HOME/build-toos`的版本为`23.0.2`，同时指定`com.android.support:appcompat-v7`的版本为`24.0.0-alpha1`，其命令格式如下

```sh
hero platform build android:23.0.2:24.0.0-alpha1 -e prod
```
或者只指定`ANDROID_HOME/build-toos`为`23.0.2`，则其命令格式如下：

```sh
hero platform build android:23.0.2 -e prod
```
