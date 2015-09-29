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


gulp.task 'client-watch', ->
  gulp.watch './src/less/**/**', ['less-concat']
  gulp.watch './src/templates/**/**', ['template-concat']

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

gulp.task 'compile', ['cleanDist'], ->
  copyCSS = gulp.src './www/assets/css/**/*'
    .pipe gulp.dest "./dist/#{pkg.version}/css/"

  renderHTML = gulp.src './www/views/*.html'
    .pipe through.obj (file, enc, cb) ->
      render = hbs.create().express3
        viewsDir: './www/views'
        partialsDir: './www/views/partials'
        layoutDir: './www/views/layouts'
        defaultLayout: './www/views/layouts/layout.html'
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


gulp.task 'dev', ['less-concat', 'client-watch', 'server-watch']
