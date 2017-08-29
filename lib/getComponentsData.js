let fs = require('fs')
let babel = require('babel-core')
let traverse = require('babel-traverse')
let chalk = require('chalk')
let DecoratorName = 'Entry'

let entriesMetas = {}

function getComponentsData(fileAbsolutePath) {
  let paths = global.paths

  if (fileAbsolutePath === paths.appIndexJs) {
    // Index.js will always generate HTML, Ignore this file
    return false
  }
  // console.log('fileAbsolutePath=' + fileAbsolutePath);
  let code = fs.readFileSync(fileAbsolutePath, 'UTF-8')

  let ast = babel.transform(code, {
    ast: true,
    babelrc: false,
    compact: 'auto',
    sourceMaps: false,
    code: true,
    comments: false,
    minified: false,
    sourceType: 'module',
    presets: [
      require.resolve('babel-preset-es2015'),
      require.resolve('babel-preset-stage-2')
    ],
    plugins: [
      require.resolve('babel-plugin-transform-class-properties'),
      require.resolve('babel-plugin-transform-object-rest-spread'),
      require.resolve('babel-plugin-transform-decorators-legacy')
    ]
  })

  // console.log(ast.code);

  let isFounded = false
  let templateAttributes = {}

  traverse.default(ast.ast, {
    enter(path) {
      let node = path.node

      if (!isFounded && node.type === 'CallExpression') {
        if (node.callee.expressions &&
                    // && node.arguments
                    // && node.arguments.length
                    node.callee.expressions.find(function(exp) {
                      return exp.type === 'MemberExpression' &&
                        exp.object &&
                        exp.object.type === 'Identifier' &&
                        exp.object.name.indexOf('_decorator') === 0 &&
                        exp.property.type === 'Identifier' &&
                        exp.property.name === DecoratorName
                    })) {
          // console.log(JSON.stringify(node));
          isFounded = true

          if (!node.arguments || !node.arguments.length) {
            return
          }
          if (node.arguments.length > 1) {
            console.log(chalk.yellow('Arguments Length in @' + DecoratorName + ' Exceed, Ignore the arguments except the first one.'))
          }
          if (node.arguments[0].type !== 'ObjectExpression') {
            console.log(chalk.yellow('Arguments in @' + DecoratorName + ' should be plain object, Not Support Dynamic Attributes or Function Return Value'))
            return
          }

          node.arguments[0].properties.forEach(function(prop) {
            if (prop.type !== 'ObjectProperty') {
              console.log(chalk.yellow('Configuration in @' + DecoratorName + ' should be plain object, Not Dynamic Attributes'))
              return false
            }
            if (prop.key.type !== 'Identifier') {
              console.log(chalk.yellow('Configuration Key ' + prop.key + ' in @' + DecoratorName + ' should be static, Not Dynamic Attributes'))
              return
            }
            if (prop.value.type !== 'StringLiteral') {
              console.log(chalk.yellow('Value of Key [' + prop.key.name + '] in @' + DecoratorName + ' should be String, Not a variable.'))
              return
            }
            templateAttributes[prop.key.name] = prop.value.value
          })
        }
      }
    }
  })

  if (isFounded) {
    // console.log('templateAttributes', templateAttributes);
    entriesMetas[fileAbsolutePath] = templateAttributes
    return templateAttributes
  }
  return null
}

module.exports = {
  getComponentsData: getComponentsData,
  entriesMetas: entriesMetas
}
