gulp = require 'gulp'
concat = require 'gulp-concat'
rename = require 'gulp-rename'
less = require 'gulp-less'
minifyCSS = require 'gulp-minify-css'
minifyHTML = require 'gulp-minify-html'
sourcemaps = require 'gulp-sourcemaps'
uglify = require 'gulp-uglify'
merge = require 'merge-stream'
nodemon = require 'nodemon'
hbs = require 'express-hbs'
through = require 'through2'
clean = require 'gulp-clean'
coffee = require 'gulp-coffee'
addSrc = require 'gulp-add-src'
jasmine = require 'gulp-jasmine-phantom'
replace = require 'gulp-replace'
svgstore = require 'gulp-svgstore'
svgmin = require 'gulp-svgmin'
pkg = require './package.json'

__base = './www/'

gulp.task 'less-concat', ->
  cyclops = gulp.src './src/less/cyclops.less'
    .pipe sourcemaps.init()
    .pipe less()
    .pipe sourcemaps.write './'
    .pipe gulp.dest './www/assets/css'

  site = gulp.src './src/less/site/site.less'
    .pipe sourcemaps.init()
    .pipe less()
    .pipe sourcemaps.write './'
    .pipe gulp.dest './www/assets/css'

    return merge cyclops, site

gulp.task 'less-min', ->
  return gulp.src './src/less/cyclops.less'
    .pipe sourcemaps.init()
    .pipe less()
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
  gulp.src './src/scripts/helpers/init.coffee'
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
    .pipe addSrc.prepend './build/before.js'
    .pipe addSrc.append './build/after.js'
    .pipe sourcemaps.init()
    .pipe concat('cyclops.js')
    .pipe sourcemaps.write './'
    .pipe gulp.dest './www/assets/scripts'

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

gulp.task 'test', ['test-run'], ->
  gulp.src './temp'
    .pipe clean()

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

gulp.task 'dev', ['less-concat', 'template-concat', 'svg-concat', 'script-concat', 'client-watch', 'server-watch']

gulp.task 'build', ['less-concat', 'template-concat', 'svg-concat', 'script-concat']

gulp.task 'dist', ['compile'], ->
  console.log 'To distribute a new version of cyclops'
  console.log '     * Pull and get latests from https://github.com/CenturyLinkCloud/AssetsServer.git'
  console.log '     * Copy the contents of the \'dist\' folder from Cyclops to the the \'cyclops\' folder'
  console.log '     * Commit the changes to the AssetsServer Repository'
  console.log '     * Create a tag for the release in this repository'
  console.log "         * git tag -a v#{pkg.version} -m 'Add tag v#{pkg.version}'"
  console.log '         * git push origin --tags'
  console.log '     * Go bump the version in package.json to the next version and commit that as a \'version bump\''


# TRAVIS CRAP
gulp.task 'travis-compile', ['less-concat', 'script-concat', 'template-concat', 'svg-concat'], ->
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

  return merge copyCSS, copyScripts, copyTemplates, copySvg, copyStarterPages, copyExamplePages, copyImages, renderHTML, copyStaticBuildPackFiles
