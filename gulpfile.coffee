#
# Cyclops Build Script
#
# Provides the tasks for building, testing and distributing the Cyclops project
# through the use of Gulp.
#

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
# * Removed unused examplePages/leftNav.html (TODO is this truly unused?)
# * Moved www/views to src/views and www/assets/img to src/images
# * Moved build/before.js and build/after.js to src/scripts, as I need build/ for build output.
# * Moved src/less to src/stylesheets, as my crystal ball says we'll probably end up using Sass in the future.
# * Everything old is new again.
# * Eliminated the 2 code paths we had before for compiling views. We now just compile with `gulp dev` or `gulp watch` instead of via the app server and the dist.
# * Removed nodemon and all the express-related files (app.coffee, config.coffee and routes.coffee). Now that we have the intermediate build step, we can just serve all static content in development.
# * Prefixed the globals from scripts/helpers/init.coffee with window. so that the globals (blech) can still be accessed by tests when wrapped by before.js and after.js. This is a definite fixme.
# * Introduces gulp-live-server for automatically refreshing as you make changes.
#

# TODO: Rename src/less to src/stylesheets
# TODO: Consider... and with a big question mark... vendorizing all of the 3rd-party scripts that we _depend_ on. (i.e. jQuery, knockout, etc) so that we can control the deployed versions of these.

# Configuration ----------------------------------------------------------------

BUILD_OUTPUT = 'build'
DISTRIBUTION_OUTPUT = 'dist'

AUTOPREFIXER_OPTIONS = {
  browsers: [ 'ie >= 9', 'last 2 versions' ],
  cascade: false
}

DEVELOPMENT_PORT = process.env.PORT or '4000'

# Primary Tasks ----------------------------------------------------------------

gulp.task 'build', [
  'images', 'scripts', 'stylesheets', 'templates', 'views', 'screenshots'
]

gulp.task 'clean', [
  'clean-images', 'clean-scripts', 'clean-stylesheets', 'clean-templates',
  'clean-tests', 'clean-distribution'
]
#, ->
# TODO: Because it's not very easy to clean up the built views, as they are
#       copied into the build tree... We could put views in build/views and
#       have a final step that constructs the output tree into something like
#       build/output to make it easier to clean the view step, but not sure if
#       that's worthwhile at the moment...
# gulp.src(BUILD_OUTPUT).pipe(clean())

gulp.task 'dev', [
  'build', 'watch', 'serve'
]

gulp.task 'dist', [
  'clean', 'build', 'test', 'distribute'
]

# Stylesheet Tasks -------------------------------------------------------------

gulp.task 'stylesheets', [ 'compile-stylesheets', 'optimize-stylesheets' ]

gulp.task 'clean-stylesheets', ->
  gulp.src("#{BUILD_OUTPUT}/cyclops/css").pipe clean()

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
  gulp.src("#{BUILD_OUTPUT}/cyclops/scripts").pipe clean()

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
        '!src/scripts/validators/register.coffee'
      ]
      addSrc.append 'src/scripts/validators/register.coffee'
      addSrc.append 'src/scripts/*.*'
      addSrc.prepend 'src/scripts/polyfills/**/*.coffee'
      coffee { bare: true }
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
  gulp.src("#{BUILD_OUTPUT}/cyclops/templates").pipe clean()

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
  gulp.src("#{BUILD_OUTPUT}/cyclops/svg").pipe clean()

gulp.task 'compile-images', ->
  gulp.src 'src/images/**/*'
    .pipe gulp.dest "#{BUILD_OUTPUT}/cyclops/img"
  gulp.src 'src/svg/**/*.svg'
    .pipe rename { prefix: 'icon-' }
    .pipe svgstore { inlineSvg: true }
    .pipe rename 'cyclops.icons.svg'
    .pipe gulp.dest "#{BUILD_OUTPUT}/cyclops/svg"

gulp.task 'optimize-images', [ 'compile-images' ], ->
  # TODO: pngcrush, etc?
  gulp.src "#{BUILD_OUTPUT}/cyclops/svg/*.svg"
    .pipe svgmin()
    .pipe rename 'cyclops.icons.min.svg'
    .pipe gulp.dest "#{BUILD_OUTPUT}/cyclops/svg"

# View Tasks -------------------------------------------------------------------

gulp.task 'views', [ 'compile-views' ]

gulp.task 'clean-views', ->
  console.log('TODO')

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
        version: pkg.version
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

gulp.task 'screenshots', [ 'take-screenshots' ]

gulp.task 'clean-screenshots', ->
  gulp.src("#{BUILD_OUTPUT}/cyclops/img/screenshots").pipe clean()

gulp.task 'take-screenshots', ->
  gulp.src "#{BUILD_OUTPUT}/cyclops/starterPages/*.html"
    .pipe webshot {
      dest: "#{BUILD_OUTPUT}/cyclops/img/screenshots",
      root: "."
      renderDelay: 3000
      flatten: true
    }

# Test Tasks -------------------------------------------------------------------

gulp.task 'test', [ 'compile-tests', 'execute-tests' ]

gulp.task 'clean-tests', ->
  gulp.src("#{BUILD_OUTPUT}/tests").pipe clean()

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
      # TODO: It bothers me that this is not in sync with (or can easily lose sync with) what is actually included...
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
  gulp.src(DISTRIBUTION_OUTPUT).pipe clean()

gulp.task 'create-distribution', [ 'clean-distribution', 'build' ], ->

  # Copy Build Output
  gulp.src "#{BUILD_OUTPUT}/cyclops"
    .pipe gulp.dest "#{DISTRIBUTION_OUTPUT}/#{pkg.version}"

  # Rewrite References to Distributed/Hosted Cyclops
  gulp.src "#{DISTRIBUTION_OUTPUT}/#{pkg.version}/**/*"
    .pipe replace /\/templates\/cyclops\.tmpl\.html/i, "https://assets.ctl.io/cyclops/#{pkg.version}/templates/cyclops.tmpl.min.html"
    .pipe replace /\/svg\/cyclops\.icons\.svg/i, "https://assets.ctl.io/cyclops/#{pkg.version}/svg/cyclops.icons.min.svg"
    .pipe replace /\/css\/cyclops\.css/i, "https://assets.ctl.io/cyclops/#{pkg.version}/css/cyclops.min.css"
    .pipe replace /\/scripts\/cyclops\.js/i, "https://assets.ctl.io/cyclops/#{pkg.version}/scripts/cyclops.min.js"
    .pipe replace /\/css\/site\.css/i, "https://assets.ctl.io/cyclops/#{pkg.version}/css/site.css"
    .pipe replace /\/img\/favicon\//gi, "https://assets.ctl.io/cyclops/#{pkg.version}/img/favicon/"
    .pipe gulp.dest "#{DISTRIBUTION_OUTPUT}/#{pkg.version}"

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

gulp.task 'watch', ->
  gulp.watch 'src/less/**/**', [ 'compile-stylesheets' ]
  gulp.watch 'src/templates/**/**', [ 'compile-templates' ]
  gulp.watch 'src/scripts/**/**', [ 'compile-scripts' ]
  gulp.watch 'src/svg/**/**', [ 'compile-images' ]
  gulp.watch 'src/views/**/**', [ 'compile-views' ]
  gulp.watch 'src/views/starterPages/**/**', [ 'take-screenshots' ]

gulp.task 'serve', ->
  server = liveServer.static "#{BUILD_OUTPUT}/cyclops", DEVELOPMENT_PORT
  server.start()
  gulp.watch "#{BUILD_OUTPUT}/cyclops/**/**", (file) ->
    server.notify.apply server, [ file ]

# Travis Tasks -----------------------------------------------------------------

# TODO: Calling this travis seems like a copout. It should probably be more like
#       compile dev site...

# gulp.task 'travis', [ 'build' ], ->
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

# ==============================================================================

# gulp.task 'cleanDist', ->
#   return gulp.src "./dist/#{pkg.version}", { read: false }
#     .pipe clean()
#
# gulp.task 'compile', ['cleanDist', 'less-min', 'script-minify', 'template-minify', 'svg-minify'], ->
#   copyCSS = gulp.src './www/assets/css/**/*'
#     .pipe gulp.dest "./dist/#{pkg.version}/css/"
#
#   copyScripts = gulp.src './www/assets/scripts/**/*'
#     .pipe replace /\/templates\/cyclops\.tmpl\.html/i, "https://assets.ctl.io/cyclops/#{pkg.version}/templates/cyclops.tmpl.min.html"
#     .pipe replace /\/svg\/cyclops\.icons\.svg/i, "https://assets.ctl.io/cyclops/#{pkg.version}/svg/cyclops.icons.min.svg"
#     .pipe gulp.dest "./dist/#{pkg.version}/scripts/"
#
#   copyTemplates = gulp.src './www/assets/templates/**/*'
#     .pipe gulp.dest "./dist/#{pkg.version}/templates/"
#
#   copySvg = gulp.src './www/assets/svg/**/*'
#     .pipe gulp.dest "./dist/#{pkg.version}/svg/"
#
#   copyStarterPages = gulp.src './www/starterPages/**/*'
#     .pipe replace /\/css\/cyclops\.css/i, "https://assets.ctl.io/cyclops/#{pkg.version}/css/cyclops.min.css"
#     .pipe replace /\/scripts\/cyclops\.js/i, "https://assets.ctl.io/cyclops/#{pkg.version}/scripts/cyclops.min.js"
#     .pipe gulp.dest "./dist/#{pkg.version}/starterPages/"
#
#   copyExamplePages = gulp.src './www/examplePages/**/*'
#     .pipe replace /\/css\/cyclops\.css/i, "https://assets.ctl.io/cyclops/#{pkg.version}/css/cyclops.min.css"
#     .pipe replace /\/scripts\/cyclops\.js/i, "https://assets.ctl.io/cyclops/#{pkg.version}/scripts/cyclops.min.js"
#     .pipe gulp.dest "./dist/#{pkg.version}/examplePages/"
#
#   copyImages = gulp.src './www/assets/img/**/*'
#     .pipe gulp.dest "./dist/#{pkg.version}/img/"
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
#     .pipe replace /\/css\/cyclops\.css/i, "https://assets.ctl.io/cyclops/#{pkg.version}/css/cyclops.min.css"
#     .pipe replace /\/css\/site\.css/i, "https://assets.ctl.io/cyclops/#{pkg.version}/css/site.css"
#     .pipe replace /\/scripts\/cyclops\.js/i, "https://assets.ctl.io/cyclops/#{pkg.version}/scripts/cyclops.min.js"
#     .pipe replace /\/img\/favicon\//gi, "https://assets.ctl.io/cyclops/#{pkg.version}/img/favicon/"
#     .pipe gulp.dest "./dist/#{pkg.version}/"
#
#   return merge copyCSS, copyScripts, copyTemplates, copySvg, copyStarterPages, copyExamplePages, copyImages, renderHTML
