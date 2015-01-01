var gulp    = require('gulp')
  , gutil   = require('gulp-util')
  , coffee  = require('gulp-coffee')
  , clint   = require('gulp-coffeelint')
  , gpp     = require('gulp-preprocess')
  ;

var srcdir = './src/';

gulp.task('default', [ 'coffeelint', 'pp' ], function(){});
gulp.task('build', [ 'default', 'coffee', 'package' ], function(){});

gulp.task('coffee', function() {
  gulp.src(srcdir + '/*.coffee')
    .pipe(coffee({ bare: true }).on('error', gutil.log))
    .pipe(gulp.dest(srcdir + '/'));
});

gulp.task('coffeelint', function() {
  gulp.src(srcdir + '/*.coffee')
    .pipe(clint())
    .pipe(clint.reporter())
    .pipe(clint.reporter('fail'));
});

gulp.task('pp', function() {
  gulp.src(srcdir + '/*.coffee')
    .pipe(gpp({ context: { DEBUG: false }}));
});
