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
  gulp.src ['./src/scripts/helpers/**/*.*',
            './src/scripts/bindings/**/*.*',
            './src/scripts/widgets/**/*.*',
            './src/scripts/models/**/*.*',
            './src/scripts/*.*']
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

gulp.task 'test-build', ->
  return gulp.src ['./src/scripts/helpers/**/*.*',
            './src/scripts/bindings/**/*.*',
            './src/scripts/widgets/**/*.*',
            './src/scripts/models/**/*.*',
            './specs/testHelpers/*.coffee',
            './specs/**/*.spec.coffee']
    .pipe coffee({bare: true})
    .pipe gulp.dest './temp'

gulp.task 'test-run', ['test-build'], ->
  return gulp.src './temp/**/*.js'
    .pipe jasmine {
            integration: true
            keepRunner: false
            vendor: [
              'https://code.jquery.com/jquery-2.1.4.min.js'
              'https://ajax.aspnetcdn.com/ajax/knockout/knockout-3.3.0.js'
              'https://cdnjs.cloudflare.com/ajax/libs/knockout-validation/2.0.3/knockout.validation.min.js'
              'https://code.jquery.com/ui/1.11.4/jquery-ui.min.js'
            ]
          }

gulp.task 'test', ['test-run'], ->
  gulp.src './temp'
    .pipe clean()

gulp.task 'client-watch', ->
  gulp.watch './src/less/**/**', ['less-concat']
  gulp.watch './src/templates/**/**', ['template-concat']
  gulp.watch './src/scripts/**/**', ['script-concat']

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

gulp.task 'compile', ['cleanDist', 'less-min', 'script-minify', 'template-minify'], ->
  copyCSS = gulp.src './www/assets/css/**/*'
    .pipe gulp.dest "./dist/#{pkg.version}/css/"

  copyScripts = gulp.src './www/assets/scripts/**/*'
    .pipe gulp.dest "./dist/#{pkg.version}/scripts/"

  copyTemplates = gulp.src './www/assets/templates/**/*'
    .pipe gulp.dest "./dist/#{pkg.version}/templates/"

  renderHTML = gulp.src './www/views/*.html'
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
    .pipe gulp.dest "./dist/#{pkg.version}/"

  return merge copyCSS, renderHTML


gulp.task 'dev', ['less-concat', 'template-concat', 'script-concat', 'client-watch', 'server-watch']
