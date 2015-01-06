#!/usr/bin/env node
var bebopt = require('./index')
  ;

var argv = bebopt()
  .longOption('help::', function() {
    this.printHelp();
    process.exit(0);
  }).shortOption('h').help('\tprint this message and exit')
  .longOption('version', function() {
    console.log('1.0');
    process.exit(0);
  }).shortOption('v').help('\tprint program version and exit')
  .shortOption('x', function() {
    this._log(this);
  }).help('\t\tblah')
  .parse();

console.log(argv);
