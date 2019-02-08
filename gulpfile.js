'use strict';

const gulp         = require( "gulp" );
const clear        = require('clear');
const rename       = require( "gulp-rename" );
const flatten      = require('gulp-flatten');
const concat       = require('gulp-concat');

// SCSS
const sass         = require('gulp-sass');
const sassLint     = require('gulp-sass-lint');
const autoprefixer = require('gulp-autoprefixer');
// JS
const eslint = require('gulp-eslint');

const dest = 'http/';
const src = 'build/';
const paths = {
  index:{
    source: [src+'index.html', src+'index.php', src+'.htaccess'],
    destination: dest
  },
  images: {
    source: src+'**/*.+(png|jpg|jpeg|svg)',
    destination: dest+'img'
  },
  scss: {
    source: src+'**/*.scss',
    destination: dest+'css/'
  },
  js: {
    source: src+'**/*.js',
    destination: dest+'js'
  }
};

/**
* IMAGES
**/
function images(){
  return gulp.src(paths.images.source, { allowEmpty: true })
  .pipe(flatten())
  .pipe(gulp.dest(paths.images.destination));
}
gulp.task( "images", images );

/**
* JS 
**/
function js() {
  return gulp.src(paths.js.source, { allowEmpty: true })
  .pipe(flatten())
  .pipe(gulp.dest(paths.js.destination));
}
gulp.task( "js", js );

/**
* SASS
**/
function scss() {
  clear();
  return gulp.src(paths.scss.source, { allowEmpty: true })
  .pipe(flatten())
  .pipe(sassLint({configFile: './.scss-lint.yml'}))
  .pipe(sassLint.format())
  .pipe(sassLint.failOnError())
  .pipe(sass({
    outputStyle: 'compressed'
  }).on('error', sass.logError))
  .pipe(autoprefixer({
    browsers: ['last 2 versions'],
    cascade: false
  }))
  .pipe(gulp.dest(paths.scss.destination));
}

function scssLint() {
  return gulp.src(paths.scss.source, { allowEmpty: true })
  .pipe(sassLint({configFile: './.scss-lint.yml'}))
  .pipe(sassLint.format())
  .pipe(sassLint.failOnError())
}

gulp.task( "scss:lint", scssLint );
gulp.task( "scss", gulp.series(scssLint, scss) );

/**
* HTML
**/
function index() {
  return gulp.src(paths.index.source, { allowEmpty: true })
  .pipe(gulp.dest(paths.index.destination));
}

gulp.task( "index", index );

/**
* META
**/
function watch() {
  gulp.watch( paths.images.source, { usePolling: true }, images );
  gulp.watch( paths.js.source, { usePolling: true }, js );
  gulp.watch( paths.scss.source, { usePolling: true }, scss );
  gulp.watch( paths.index.source, { usePolling: true }, index );
}
gulp.task( "default", gulp.series(scss, images, js, index, watch ) );
