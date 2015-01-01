var gulp    = require('gulp')
  , gutil   = require('gulp-util')
  , coffee  = require('gulp-coffee')
  , clint   = require('gulp-coffeelint')
  ;

gulp.task('default', [ 'coffeelint', 'pp' ], function(){});
gulp.task('build', [ 'default', 'coffee', 'package' ], function(){});
gulp.task('coffee', function() {
  gulp.src('*.coffee')
    .pipe(coffee({ bare: true }).on('error', gutil.log));
});
gulp.task('coffeelint', function() {
  gulp.src('./lib/*.coffee')
    .pipe(clint())
    .pipe(clint.reporter())
});
