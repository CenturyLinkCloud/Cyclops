gulp = require 'gulp'
addSrc = require 'gulp-add-src'
autoprefixer = require 'gulp-autoprefixer'
clean = require 'gulp-clean'
coffee = require 'gulp-coffee'
combine = require 'stream-combiner2'
concat = require 'gulp-concat'
hbs = require 'express-hbs'
jasmine = require 'gulp-jasmine-phantom'
less = require 'gulp-less'
liveServer = require 'gulp-live-server'
merge = require 'merge-stream'
minifyCSS = require 'gulp-minify-css'
minifyHTML = require 'gulp-minify-html'
notifier = require 'node-notifier'
pkg = require './package.json'
rename = require 'gulp-rename'
replace = require 'gulp-replace'
sourcemaps = require 'gulp-sourcemaps'
svgmin = require 'gulp-svgmin'
svgstore = require 'gulp-svgstore'
through = require 'through2'
uglify = require 'gulp-uglify'
webshot = require 'gulp-webshot'

# Changes:
#
# * Fixes tests by including jasmine-core in package.json, although the tests themselves seem to be very broken...
# * [TODO] Moves from the deprecated minify-css to clean-css
# * Adds an intermediate build step, where build/cyclops has a fully working local copy. Dist now converts that into a distribution-ready copy by replacing URLs.
# * Removes a lot of duplicated code and splits things into easily reusable Tasks
# * Takes screenshots of sample pages automatically
# * Added the test task to the dist task so that tests must pass before you can make a dist build
# * Removed unused examplePages/leftNav.html
# * Moved www/views to src/views and www/assets/img to src/images
# * Moved build/before.js and build/after.js to src/scripts, as I need build/ for build output.
# * Moved src/less to src/stylesheets, as my crystal ball says we'll probably end up using Sass in the future.
# * Everything old is new again.
# * Eliminated the 2 code paths we had before for compiling views. We now just compile with `gulp dev` or `gulp watch` instead of via the app server and the dist.
# * Removed nodemon and all the express-related files (app.coffee, config.coffee and routes.coffee). Now that we have the intermediate build step, we can just serve all static content in development.
# *

# TODO: Rename src/less to src/stylesheets
# TODO: Move www to src/www

# Configuration ----------------------------------------------------------------

DEVELOPMENT_PORT = '4000'
BUILD_OUTPUT = 'build'
DISTRIBUTION_OUTPUT = 'dist'
AUTOPREFIXER_OPTIONS = {
  browsers: [ 'ie >= 9', 'last 2 versions' ],
  cascade: false
}

# Primary Tasks ----------------------------------------------------------------

gulp.task 'build', [
  'images', 'scripts', 'stylesheets', 'templates', 'views', 'screenshots'
]

gulp.task 'clean', [
  'clean-images', 'clean-scripts', 'clean-stylesheets', 'clean-templates',
  'clean-tests', 'clean-distribution'
]

gulp.task 'dist', [
  'clean', 'build', 'test', 'distribute'
]

# Stylesheet Tasks -------------------------------------------------------------

gulp.task 'stylesheets', [ 'compile-stylesheets', 'optimize-stylesheets' ]

gulp.task 'clean-stylesheets', ->
  gulp.src "#{BUILD_OUTPUT}/cyclops/css", { read: false }
    .pipe clean()

gulp.task 'compile-stylesheets', ->
  concatenated = combine.obj [
    gulp.src [ 'src/less/cyclops.less', 'src/less/site/site.less' ]
      sourcemaps.init()
      less()
      autoprefixer AUTOPREFIXER_OPTIONS
      sourcemaps.write '.'
      gulp.dest "#{BUILD_OUTPUT}/cyclops/css"
  ]
  concatenated.on 'error', (error) ->
    console.error.bind(console)
    notifier.notify
      title: 'Stylesheet Compilation Error'
      message: error.message
      icon: './www/assets/img/centurylink-cyclops.png'
  concatenated

gulp.task 'optimize-stylesheets', [ 'compile-stylesheets' ], ->
  gulp.src [ "#{BUILD_OUTPUT}/cyclops/css/cyclops.css", "#{BUILD_OUTPUT}/cyclops/css/site.css" ]
    .pipe sourcemaps.init()
    .pipe minifyCSS()
    .pipe rename { suffix: '.min' }
    .pipe sourcemaps.write '.'
    .pipe gulp.dest "#{BUILD_OUTPUT}/cyclops/css"

# Script Tasks -----------------------------------------------------------------

gulp.task 'scripts', [ 'compile-scripts', 'optimize-scripts' ]

gulp.task 'clean-scripts', ->
  gulp.src "#{BUILD_OUTPUT}/cyclops/scripts", { read: false }
    .pipe clean()

gulp.task 'compile-scripts', ->
  concatenated = combine.obj [
    gulp.src 'src/scripts/helpers/init.coffee'
      addSrc.append [
        'src/scripts/helpers/**/*.*',
        '!src/scripts/helpers/init.coffee'
      ]
      addSrc.append 'src/scripts/extensions/**/*.*'
      addSrc.append 'src/scripts/bindings/**/*.*'
      addSrc.append 'src/scripts/widgets/**/*.*'
      addSrc.append 'src/scripts/models/**/*.*'
      addSrc.append [
        'src/scripts/validators/**/*.*',
        '!/src/scripts/validators/register.coffee'
      ]
      addSrc.append 'src/scripts/validators/register.coffee'
      addSrc.append 'src/scripts/*.*'
      addSrc.prepend 'src/scripts/polyfills/**/*.coffee'
      coffee({ bare: true })
      addSrc.prepend 'src/before.js'
      addSrc.append 'src/after.js'
      addSrc.prepend 'src/scripts/vendor/*.js'
      sourcemaps.init()
      concat 'cyclops.js'
      sourcemaps.write '.'
      gulp.dest "#{BUILD_OUTPUT}/cyclops/scripts"
  ]
  concatenated.on 'error', (error) ->
    console.error.bind(console)
    notifier.notify
      title: 'Script Compilation Error'
      message: error.message
      icon: './www/assets/img/centurylink-cyclops.png'
  concatenated

gulp.task 'optimize-scripts', [ 'compile-scripts' ], ->
  gulp.src "#{BUILD_OUTPUT}/cyclops/scripts/cyclops.js"
    .pipe sourcemaps.init()
    .pipe uglify()
    .pipe rename { suffix: '.min' }
    .pipe sourcemaps.write './'
    .pipe gulp.dest "#{BUILD_OUTPUT}/cyclops/scripts"

# Template Tasks ---------------------------------------------------------------

gulp.task 'templates', [ 'compile-templates', 'optimize-templates' ]

gulp.task 'clean-templates', ->
  gulp.src "#{BUILD_OUTPUT}/cyclops/templates", { read: false }
    .pipe clean()

gulp.task 'compile-templates', ->
  gulp.src 'src/templates/**/*.tmpl.html'
    .pipe sourcemaps.init()
    .pipe concat 'cyclops.tmpl.html'
    .pipe sourcemaps.write '.'
    .pipe gulp.dest "#{BUILD_OUTPUT}/cyclops/templates"

gulp.task 'optimize-templates', [ 'compile-templates' ], ->
  gulp.src "#{BUILD_OUTPUT}/cyclops/templates/*.tmpl.html"
    .pipe sourcemaps.init()
    .pipe minifyHTML { empty: true }
    .pipe rename { suffix: '.min' }
    .pipe sourcemaps.write '.'
    .pipe gulp.dest "#{BUILD_OUTPUT}/cyclops/templates"

# Image Tasks ------------------------------------------------------------------

gulp.task 'images', [ 'compile-images', 'optimize-images' ]

gulp.task 'clean-images', ->
  gulp.src "#{BUILD_OUTPUT}/cyclops/svg", { read: false }
    .pipe clean()

gulp.task 'compile-images', ->
  gulp.src 'src/svg/**/*.svg'
    .pipe rename { prefix: 'icon-' }
    .pipe svgstore { inlineSvg: true }
    .pipe rename 'cyclops.icons.svg'
    .pipe gulp.dest "#{BUILD_OUTPUT}/cyclops/svg"

gulp.task 'optimize-images', [ 'compile-images' ], ->
  gulp.src "#{BUILD_OUTPUT}/cyclops/svg/*.svg"
    .pipe svgmin()
    .pipe rename 'cyclops.icons.min.svg'
    .pipe gulp.dest "#{BUILD_OUTPUT}/cyclops/svg"

# View Tasks -------------------------------------------------------------------

gulp.task 'views', [ 'compile-views' ]

# gulp.task 'clean-views' ->

gulp.task 'compile-views', ->
  gulp.src 'src/views/**/*.html'
    .pipe through.obj (file, enc, cb) ->
      render = hbs.create().express3
        viewsDir: 'src/views'
        partialsDir: 'src/views/partials'
        layoutDir: 'src/views/layouts'
        defaultLayout: 'src/views/layouts/default.html'
        extName: 'html'

      locals = {
        settings: {
          views: 'src/views'
        },
        version: "#{pkg.version}"
        enviroment: "release"
      }

      render file.path, locals, (err, html) =>
        if (!err)
          file.contents = new Buffer(html)
          this.push(file)
          cb()
        else
          console.log "failed to render #{file.path}"
    .pipe gulp.dest "#{BUILD_OUTPUT}/cyclops"

# Screenshot Tasks (for Sample Pages) ------------------------------------------

gulp.task 'screenshots' #, [ 'take-screenshots' ]

# gulp.task 'clean-screenshots', ->
#   # gulp.src "#{BUILD_OUTPUT}/assets/svg", { read: false }
#   #   .pipe clean()

# gulp.task 'take-screenshots', [ 'build' ], ->
#   gulp.src "#{BUILD_OUTPUT}/starterPages/*.html"
#     .pipe webshot {
#       dest: './www/assets/img/screenshots',
#       root: "www/views/starterPages",
#       screenSize: { width: 1600, height: 1024 }
#     }

# Test Tasks -------------------------------------------------------------------

gulp.task 'test', [ 'compile-tests', 'execute-tests' ]

gulp.task 'clean-tests', ->
  gulp.src "#{BUILD_OUTPUT}/tests", { read: false }
    .pipe clean()

gulp.task 'compile-tests', [ 'build' ], ->
  gulp.src [ 'specs/testHelpers/*.coffee', 'specs/**/*.spec.coffee' ]
    .pipe coffee({ bare: true })
    .pipe gulp.dest "#{BUILD_OUTPUT}/tests"

gulp.task 'execute-tests', [ 'compile-tests' ], ->
  gulp.src "#{BUILD_OUTPUT}/tests/**/*.js"
    .pipe jasmine {
      abortOnFail: true
      integration: true
      keepRunner: true
      vendor: [
        'http://code.jquery.com/jquery-2.2.0.min.js'
        'http://ajax.aspnetcdn.com/ajax/knockout/knockout-3.3.0.js'
        'http://cdnjs.cloudflare.com/ajax/libs/knockout-validation/2.0.3/knockout.validation.min.js'
        'http://code.jquery.com/ui/1.11.4/jquery-ui.min.js'
        'http://cdnjs.cloudflare.com/ajax/libs/moment.js/2.11.2/moment.min.js'
        "#{BUILD_OUTPUT}/cyclops/scripts/cyclops.js"
      ]
    }

# Distribution Tasks -----------------------------------------------------------

gulp.task 'distribute', [ 'clean-distribution', 'create-distribution', 'output-distribution-help' ]

gulp.task 'clean-distribution', ->
  gulp.src DISTRIBUTION_OUTPUT, { read: false }
    .pipe clean()

gulp.task 'create-distribution', [ 'clean-distribution' ], ->
  copyCSS = gulp.src './www/assets/css/**/*'
    .pipe gulp.dest "./dist/#{pkg.version}/css/"

  copyScripts = gulp.src './www/assets/scripts/**/*'
    .pipe replace /\/templates\/cyclops\.tmpl\.html/i, "https://assets.ctl.io/cyclops/#{pkg.version}/templates/cyclops.tmpl.min.html"
    .pipe replace /\/svg\/cyclops\.icons\.svg/i, "https://assets.ctl.io/cyclops/#{pkg.version}/svg/cyclops.icons.min.svg"
    .pipe gulp.dest "./dist/#{pkg.version}/scripts/"

  copyTemplates = gulp.src './www/assets/templates/**/*'
    .pipe gulp.dest "./dist/#{pkg.version}/templates/"

  copySvg = gulp.src './www/assets/svg/**/*'
    .pipe gulp.dest "./dist/#{pkg.version}/svg/"

  copyStarterPages = gulp.src './www/starterPages/**/*'
    .pipe replace /\/css\/cyclops\.css/i, "https://assets.ctl.io/cyclops/#{pkg.version}/css/cyclops.min.css"
    .pipe replace /\/scripts\/cyclops\.js/i, "https://assets.ctl.io/cyclops/#{pkg.version}/scripts/cyclops.min.js"
    .pipe gulp.dest "./dist/#{pkg.version}/starterPages/"

  copyExamplePages = gulp.src './www/examplePages/**/*'
    .pipe replace /\/css\/cyclops\.css/i, "https://assets.ctl.io/cyclops/#{pkg.version}/css/cyclops.min.css"
    .pipe replace /\/scripts\/cyclops\.js/i, "https://assets.ctl.io/cyclops/#{pkg.version}/scripts/cyclops.min.js"
    .pipe gulp.dest "./dist/#{pkg.version}/examplePages/"

  copyImages = gulp.src './www/assets/img/**/*'
    .pipe gulp.dest "./dist/#{pkg.version}/img/"

  renderHTML = gulp.src './www/views/**/*.html'
    .pipe through.obj (file, enc, cb) ->
      render = hbs.create().express3
        viewsDir: './www/views'
        partialsDir: './www/views/partials'
        layoutDir: './www/views/layouts'
        defaultLayout: './www/views/layouts/default.html'
        extName: 'html'

      locals = {
        settings: {
          views: './www/views'
        },
        version: "#{pkg.version}"
        enviroment: "release"
      }

      self = this;
      render file.path, locals, (err, html) ->
        if(!err)
          file.contents = new Buffer(html);
          self.push(file);
          cb();
        else
          console.log "failed to render #{file.path}"
    .pipe replace /\/css\/cyclops\.css/i, "https://assets.ctl.io/cyclops/#{pkg.version}/css/cyclops.min.css"
    .pipe replace /\/css\/site\.css/i, "https://assets.ctl.io/cyclops/#{pkg.version}/css/site.css"
    .pipe replace /\/scripts\/cyclops\.js/i, "https://assets.ctl.io/cyclops/#{pkg.version}/scripts/cyclops.min.js"
    .pipe replace /\/img\/favicon\//gi, "https://assets.ctl.io/cyclops/#{pkg.version}/img/favicon/"
    .pipe gulp.dest "./dist/#{pkg.version}/"

  return merge copyCSS, copyScripts, copyTemplates, copySvg, copyStarterPages, copyExamplePages, copyImages, renderHTML

gulp.task 'output-distribution-help', ->
  console.log 'To distribute a new version of Cyclops:'
  console.log '  * Pull and get latests from https://github.com/CenturyLinkCloud/AssetsServer.git'
  console.log '  * Copy the contents of the \'dist\' folder from Cyclops to the the \'cyclops\' folder'
  console.log '  * Commit the changes to the AssetsServer Repository'
  console.log '  * Create a tag for the release in this repository'
  console.log "      * git tag -a v#{pkg.version} -m 'Add tag v#{pkg.version}'"
  console.log '      * git push origin --tags'
  console.log '  * Go bump the version in package.json to the next version and commit that as a \'version bump\''

# Development Tasks ------------------------------------------------------------

gulp.task 'dev', [ 'build', 'watch', 'serve' ]

gulp.task 'watch', ->
  gulp.watch 'src/less/**/**', [ 'compile-stylesheets' ]
  gulp.watch 'src/templates/**/**', [ 'compile-templates' ]
  gulp.watch 'src/scripts/**/**', [ 'compile-scripts' ]
  gulp.watch 'src/svg/**/**', [ 'compile-images' ]
  # TODO Watch the example pages and regenerate screenshots when necessary

gulp.task 'serve', ->
  server = liveServer.static('build/cyclops', DEVELOPMENT_PORT)
  server.start()

# Travis Tasks -----------------------------------------------------------------

gulp.task 'travis', [ 'build' ], ->
  copyCSS = gulp.src './www/assets/css/**/*'
    .pipe gulp.dest "./devDist/css/"

  copyScripts = gulp.src './www/assets/scripts/**/*'
    .pipe replace /\/templates\/cyclops\.tmpl\.html/i, "https://cyclops-dev.uswest.appfog.ctl.io/templates/cyclops.tmpl.html"
    .pipe replace /\/svg\/cyclops\.icons\.svg/i, "https://cyclops-dev.uswest.appfog.ctl.io/svg/cyclops.icons.svg"
    .pipe gulp.dest "./devDist/scripts/"

  copyTemplates = gulp.src './www/assets/templates/**/*'
    .pipe gulp.dest "./devDist/templates/"

  copySvg = gulp.src './www/assets/svg/**/*'
    .pipe gulp.dest "./devDist/svg/"

  copyStarterPages = gulp.src './www/starterPages/**/*'
    .pipe replace /\/css\/cyclops\.css/i, "https://cyclops-dev.uswest.appfog.ctl.io/css/cyclops.css"
    .pipe replace /\/scripts\/cyclops\.js/i, "https://cyclops-dev.uswest.appfog.ctl.io/scripts/cyclops.js"
    .pipe gulp.dest "./devDist/starterPages/"

  copyExamplePages = gulp.src './www/examplePages/**/*'
    .pipe replace /\/css\/cyclops\.css/i, "https://cyclops-dev.uswest.appfog.ctl.io/css/cyclops.css"
    .pipe replace /\/scripts\/cyclops\.js/i, "https://cyclops-dev.uswest.appfog.ctl.io/scripts/cyclops.js"
    .pipe gulp.dest "./devDist/examplePages/"

  copyImages = gulp.src './www/assets/img/**/*'
    .pipe gulp.dest "./devDist/img/"

  renderHTML = gulp.src './www/views/**/*.html'
    .pipe through.obj (file, enc, cb) ->
      render = hbs.create().express3
        viewsDir: './www/views'
        partialsDir: './www/views/partials'
        layoutDir: './www/views/layouts'
        defaultLayout: './www/views/layouts/default.html'
        extName: 'html'

      locals = {
        settings: {
          views: './www/views'
        },
        version: "#{pkg.version}"
        enviroment: "release"
      }

      self = this;
      render file.path, locals, (err, html) ->
        if(!err)
          file.contents = new Buffer(html);
          self.push(file);
          cb();
        else
          console.log "failed to render #{file.path}"
    .pipe replace /\/css\/cyclops\.css/i, "https://cyclops-dev.uswest.appfog.ctl.io/css/cyclops.css"
    .pipe replace /\/css\/site\.css/i, "https://cyclops-dev.uswest.appfog.ctl.io/css/site.css"
    .pipe replace /\/scripts\/cyclops\.js/i, "https://cyclops-dev.uswest.appfog.ctl.io/scripts/cyclops.js"
    .pipe replace /\/img\/favicon\//gi, "https://assets.ctl.io/cyclops/#{pkg.version}/img/favicon/"
    .pipe gulp.dest "./devDist/"

  copyStaticBuildPackFiles = gulp.src ['./.travis/Staticfile','./.travis/nginx.conf']
    .pipe gulp.dest './devDist/'

  merge copyCSS, copyScripts, copyTemplates, copySvg, copyStarterPages, copyExamplePages, copyImages, renderHTML, copyStaticBuildPackFiles

# ==============================================================================

gulp.task 'less-concat', ->
  concatenated = combine.obj [
    gulp.src [ './src/less/cyclops.less', './src/less/site/site.less' ]
      sourcemaps.init()
      less()
      autoprefixer
        browsers: [ 'ie >= 9', 'last 2 versions' ]
        cascade: false
      sourcemaps.write './'
      gulp.dest './www/assets/css'
  ]
  concatenated.on 'error', (error) ->
    console.error.bind(console)
    notifier.notify
      title: 'Less Compilation Error'
      message: error.message
      icon: './www/assets/img/centurylink-cyclops.png'
  concatenated

gulp.task 'less-min', ->
  return gulp.src './src/less/cyclops.less'
    .pipe sourcemaps.init()
    .pipe less()
    .pipe autoprefixer
      browsers: [ 'ie >= 9', 'last 2 versions' ]
      cascade: false
    .pipe minifyCSS()
    .pipe rename { suffix: '.min' }
    .pipe sourcemaps.write './'
    .pipe gulp.dest './www/assets/css'

gulp.task 'less', ['less-concat', 'less-min']

gulp.task 'template-concat', ->
  gulp.src './src/templates/**/*.tmpl.html'
    .pipe sourcemaps.init()
    .pipe concat 'cyclops.tmpl.html'
    .pipe sourcemaps.write './'
    .pipe gulp.dest './www/assets/templates'

gulp.task 'template-minify', ['template-concat'], ->
  gulp.src ['./www/assets/templates/cyclops.tmpl.html']
    .pipe sourcemaps.init()
    .pipe minifyHTML { empty: true }
    .pipe rename { suffix: '.min' }
    .pipe sourcemaps.write './'
    .pipe gulp.dest './www/assets/templates'

gulp.task 'script-concat', ->
  concatenated = combine.obj [
    gulp.src './src/scripts/helpers/init.coffee'
      addSrc.append [ './src/scripts/helpers/**/*.*', '!./src/scripts/helpers/init.coffee' ]
      addSrc.append './src/scripts/extensions/**/*.*'
      addSrc.append './src/scripts/bindings/**/*.*'
      addSrc.append './src/scripts/widgets/**/*.*'
      addSrc.append './src/scripts/models/**/*.*'
      addSrc.append [ './src/scripts/validators/**/*.*', '!./src/scripts/validators/register.coffee' ]
      addSrc.append './src/scripts/validators/register.coffee'
      addSrc.append './src/scripts/*.*'
      addSrc.prepend './src/scripts/polyfills/**/*'
      coffee({ bare: true })
      addSrc.prepend './build/before.js'
      addSrc.append './build/after.js'
      addSrc.prepend './src/scripts/vendor/polyfill.js'
      sourcemaps.init()
      concat('cyclops.js')
      sourcemaps.write './'
      gulp.dest './www/assets/scripts'
  ]
  concatenated.on 'error', (error) ->
    console.error.bind(console)
    notifier.notify
      title: 'Script Compilation Error'
      message: error.message
      icon: './www/assets/img/centurylink-cyclops.png'
  concatenated

gulp.task 'script-minify', ['script-concat'], ->
  gulp.src ['./www/assets/scripts/cyclops.js']
    .pipe sourcemaps.init()
    .pipe uglify()
    .pipe rename { suffix: '.min' }
    .pipe sourcemaps.write './'
    .pipe gulp.dest './www/assets/scripts'

gulp.task 'svg-concat', ->
  gulp.src './src/svg/**/*.svg'
    .pipe rename { prefix: 'icon-' }
    .pipe svgstore { inlineSvg: true }
    .pipe rename 'cyclops.icons.svg'
    .pipe gulp.dest './www/assets/svg/'

gulp.task 'svg-minify', ['svg-concat'], ->
  gulp.src './src/svg/**/*.svg'
    .pipe rename { prefix: 'icon-' }
    .pipe svgmin()
    .pipe svgstore { inlineSvg: true }
    .pipe rename 'cyclops.icons.min.svg'
    .pipe gulp.dest './www/assets/svg/'

gulp.task 'test-build', ->
  buildCyclops = gulp.src './src/scripts/helpers/init.coffee'
    .pipe addSrc.append ['./src/scripts/helpers/**/*.*',
      '!./src/scripts/helpers/init.coffee']
    .pipe addSrc.append './src/scripts/extensions/**/*.*'
    .pipe addSrc.append './src/scripts/bindings/**/*.*'
    .pipe addSrc.append './src/scripts/widgets/**/*.*'
    .pipe addSrc.append './src/scripts/models/**/*.*'
    .pipe addSrc.append ['./src/scripts/validators/**/*.*',
      '!./src/scripts/validators/register.coffee']
    .pipe addSrc.append './src/scripts/validators/register.coffee'
    .pipe addSrc.append './src/scripts/*.*'
    .pipe coffee({bare: true})
    .pipe sourcemaps.init()
    .pipe concat('cyclops.test.only.js')
    .pipe sourcemaps.write './'
    .pipe gulp.dest './temp'

  buildTests = gulp.src ['./specs/testHelpers/*.coffee', './specs/**/*.spec.coffee']
    .pipe coffee({bare: true})
    .pipe gulp.dest './temp/tests'

  return merge buildCyclops, buildTests

gulp.task 'test-run', ['test-build'], ->
  return gulp.src './temp/tests/**/*.js'
    .pipe jasmine {
            abortOnFail: true
            integration: true
            keepRunner: true
            vendor: [
              'http://code.jquery.com/jquery-2.2.0.min.js'
              'http://ajax.aspnetcdn.com/ajax/knockout/knockout-3.3.0.js'
              'http://cdnjs.cloudflare.com/ajax/libs/knockout-validation/2.0.3/knockout.validation.min.js'
              'http://code.jquery.com/ui/1.11.4/jquery-ui.min.js'
              'http://cdnjs.cloudflare.com/ajax/libs/moment.js/2.11.2/moment.min.js'
              './temp/cyclops.test.only.js'
            ]
          }

# gulp.task 'test', ['test-run'], ->
#   gulp.src './temp'
#     .pipe clean()

gulp.task 'client-watch', ->
  gulp.watch './src/less/**/**', ['less-concat']
  gulp.watch './src/templates/**/**', ['template-concat']
  gulp.watch './src/scripts/**/**', ['script-concat']
  gulp.watch './src/svg/**/**', ['svg-concat']

gulp.task 'server-watch', ->
  return nodemon
    script: 'app.coffee'
    ext: 'js,coffee'
    ignore: [
      './gulpfile.coffee'
      'node_modules/*'
      'src/*'
      'www/*'
      '.git/*'
    ]

gulp.task 'cleanDist', ->
  return gulp.src "./dist/#{pkg.version}", { read: false }
    .pipe clean()

gulp.task 'compile', ['cleanDist', 'less-min', 'script-minify', 'template-minify', 'svg-minify'], ->
  copyCSS = gulp.src './www/assets/css/**/*'
    .pipe gulp.dest "./dist/#{pkg.version}/css/"

  copyScripts = gulp.src './www/assets/scripts/**/*'
    .pipe replace /\/templates\/cyclops\.tmpl\.html/i, "https://assets.ctl.io/cyclops/#{pkg.version}/templates/cyclops.tmpl.min.html"
    .pipe replace /\/svg\/cyclops\.icons\.svg/i, "https://assets.ctl.io/cyclops/#{pkg.version}/svg/cyclops.icons.min.svg"
    .pipe gulp.dest "./dist/#{pkg.version}/scripts/"

  copyTemplates = gulp.src './www/assets/templates/**/*'
    .pipe gulp.dest "./dist/#{pkg.version}/templates/"

  copySvg = gulp.src './www/assets/svg/**/*'
    .pipe gulp.dest "./dist/#{pkg.version}/svg/"

  copyStarterPages = gulp.src './www/starterPages/**/*'
    .pipe replace /\/css\/cyclops\.css/i, "https://assets.ctl.io/cyclops/#{pkg.version}/css/cyclops.min.css"
    .pipe replace /\/scripts\/cyclops\.js/i, "https://assets.ctl.io/cyclops/#{pkg.version}/scripts/cyclops.min.js"
    .pipe gulp.dest "./dist/#{pkg.version}/starterPages/"

  copyExamplePages = gulp.src './www/examplePages/**/*'
    .pipe replace /\/css\/cyclops\.css/i, "https://assets.ctl.io/cyclops/#{pkg.version}/css/cyclops.min.css"
    .pipe replace /\/scripts\/cyclops\.js/i, "https://assets.ctl.io/cyclops/#{pkg.version}/scripts/cyclops.min.js"
    .pipe gulp.dest "./dist/#{pkg.version}/examplePages/"

  copyImages = gulp.src './www/assets/img/**/*'
    .pipe gulp.dest "./dist/#{pkg.version}/img/"

  renderHTML = gulp.src './www/views/**/*.html'
    .pipe through.obj (file, enc, cb) ->
      render = hbs.create().express3
        viewsDir: './www/views'
        partialsDir: './www/views/partials'
        layoutDir: './www/views/layouts'
        defaultLayout: './www/views/layouts/default.html'
        extName: 'html'

      locals = {
        settings: {
          views: './www/views'
        },
        version: "#{pkg.version}"
        enviroment: "release"
      }

      self = this;
      render file.path, locals, (err, html) ->
        if(!err)
          file.contents = new Buffer(html);
          self.push(file);
          cb();
        else
          console.log "failed to render #{file.path}"
    .pipe replace /\/css\/cyclops\.css/i, "https://assets.ctl.io/cyclops/#{pkg.version}/css/cyclops.min.css"
    .pipe replace /\/css\/site\.css/i, "https://assets.ctl.io/cyclops/#{pkg.version}/css/site.css"
    .pipe replace /\/scripts\/cyclops\.js/i, "https://assets.ctl.io/cyclops/#{pkg.version}/scripts/cyclops.min.js"
    .pipe replace /\/img\/favicon\//gi, "https://assets.ctl.io/cyclops/#{pkg.version}/img/favicon/"
    .pipe gulp.dest "./dist/#{pkg.version}/"

  return merge copyCSS, copyScripts, copyTemplates, copySvg, copyStarterPages, copyExamplePages, copyImages, renderHTML

# gulp.task 'dev', ['less-concat', 'template-concat', 'svg-concat', 'script-concat', 'client-watch', 'server-watch']

# gulp.task 'build', ['less-concat', 'template-concat', 'svg-concat', 'script-concat']

# gulp.task 'dist', ['compile'], ->
#   console.log 'To distribute a new version of cyclops'
#   console.log '     * Pull and get latests from https://github.com/CenturyLinkCloud/AssetsServer.git'
#   console.log '     * Copy the contents of the \'dist\' folder from Cyclops to the the \'cyclops\' folder'
#   console.log '     * Commit the changes to the AssetsServer Repository'
#   console.log '     * Create a tag for the release in this repository'
#   console.log "         * git tag -a v#{pkg.version} -m 'Add tag v#{pkg.version}'"
#   console.log '         * git push origin --tags'
#   console.log '     * Go bump the version in package.json to the next version and commit that as a \'version bump\''


# TRAVIS CRAP
# gulp.task 'travis-compile', ['less-concat', 'script-concat', 'template-concat', 'svg-concat'], ->
#   copyCSS = gulp.src './www/assets/css/**/*'
#     .pipe gulp.dest "./devDist/css/"
#
#   copyScripts = gulp.src './www/assets/scripts/**/*'
#     .pipe replace /\/templates\/cyclops\.tmpl\.html/i, "https://cyclops-dev.uswest.appfog.ctl.io/templates/cyclops.tmpl.html"
#     .pipe replace /\/svg\/cyclops\.icons\.svg/i, "https://cyclops-dev.uswest.appfog.ctl.io/svg/cyclops.icons.svg"
#     .pipe gulp.dest "./devDist/scripts/"
#
#   copyTemplates = gulp.src './www/assets/templates/**/*'
#     .pipe gulp.dest "./devDist/templates/"
#
#   copySvg = gulp.src './www/assets/svg/**/*'
#     .pipe gulp.dest "./devDist/svg/"
#
#   copyStarterPages = gulp.src './www/starterPages/**/*'
#     .pipe replace /\/css\/cyclops\.css/i, "https://cyclops-dev.uswest.appfog.ctl.io/css/cyclops.css"
#     .pipe replace /\/scripts\/cyclops\.js/i, "https://cyclops-dev.uswest.appfog.ctl.io/scripts/cyclops.js"
#     .pipe gulp.dest "./devDist/starterPages/"
#
#   copyExamplePages = gulp.src './www/examplePages/**/*'
#     .pipe replace /\/css\/cyclops\.css/i, "https://cyclops-dev.uswest.appfog.ctl.io/css/cyclops.css"
#     .pipe replace /\/scripts\/cyclops\.js/i, "https://cyclops-dev.uswest.appfog.ctl.io/scripts/cyclops.js"
#     .pipe gulp.dest "./devDist/examplePages/"
#
#   copyImages = gulp.src './www/assets/img/**/*'
#     .pipe gulp.dest "./devDist/img/"
#
#   renderHTML = gulp.src './www/views/**/*.html'
#     .pipe through.obj (file, enc, cb) ->
#       render = hbs.create().express3
#         viewsDir: './www/views'
#         partialsDir: './www/views/partials'
#         layoutDir: './www/views/layouts'
#         defaultLayout: './www/views/layouts/default.html'
#         extName: 'html'
#
#       locals = {
#         settings: {
#           views: './www/views'
#         },
#         version: "#{pkg.version}"
#         enviroment: "release"
#       }
#
#       self = this;
#       render file.path, locals, (err, html) ->
#         if(!err)
#           file.contents = new Buffer(html);
#           self.push(file);
#           cb();
#         else
#           console.log "failed to render #{file.path}"
#     .pipe replace /\/css\/cyclops\.css/i, "https://cyclops-dev.uswest.appfog.ctl.io/css/cyclops.css"
#     .pipe replace /\/css\/site\.css/i, "https://cyclops-dev.uswest.appfog.ctl.io/css/site.css"
#     .pipe replace /\/scripts\/cyclops\.js/i, "https://cyclops-dev.uswest.appfog.ctl.io/scripts/cyclops.js"
#     .pipe replace /\/img\/favicon\//gi, "https://assets.ctl.io/cyclops/#{pkg.version}/img/favicon/"
#     .pipe gulp.dest "./devDist/"
#
#   copyStaticBuildPackFiles = gulp.src ['./.travis/Staticfile','./.travis/nginx.conf']
#     .pipe gulp.dest './devDist/'
#
#   merge copyCSS, copyScripts, copyTemplates, copySvg, copyStarterPages, copyExamplePages, copyImages, renderHTML, copyStaticBuildPackFiles
