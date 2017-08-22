const webpack = require('webpack')
const rm = require('rimraf')
const ora = require('ora')
const chalk = require('chalk')

const config = require('./webpack.prod.conf')

module.exports = function build() {
    const spinner = ora('building for production...')
    spinner.start()

    rm(config.output.path, err => {
        if (err) throw err

        webpack(config, (err, stats) => {
            spinner.stop()
            if (err) throw err

            process.stdout.write(stats.toString({
                colors: true,
                process: true,
                modules: false,
                children: false,
                chunks: false,
                chunkModules: false
            }) + '\n\n')

            console.log(chalk.cyan('  Build complete.\n'))
        })
    })
}


