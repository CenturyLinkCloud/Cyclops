gulp       = require 'gulp'
concat     = require 'gulp-concat'
rename     = require 'gulp-rename'
less       = require 'gulp-less'
minifyCSS  = require 'gulp-minify-css'
sourcemaps = require 'gulp-sourcemaps'
uglify     = require 'gulp-uglify'
merge      = require 'merge-stream'
nodemon    = require 'nodemon'


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

gulp.task 'client-watch', ->
  gulp.watch './src/less/**/**', ['less-concat']

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


gulp.task 'dev', ['less-concat', 'client-watch', 'server-watch']
