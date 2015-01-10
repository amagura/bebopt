#!/usr/bin/env node
var Bebopt = new (require('./index'))
  ;

var argv = Bebopt
  .usage('hello')
  .define('help::', '\tprint this message and exit', function() {
    this.printHelp();
    process.exit(0);
  }).alias('h')
  .define('version', '\tprint program version and exit', function() {
    console.log('1.0');
    process.exit(0);
  }).alias('v', 'ver')
  .define('x', '\t\tblah', function(x) {
    this.log(x);
  })
  .parse();

console.log(argv);
