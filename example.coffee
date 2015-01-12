#!/usr/bin/env coffee
Bebopt = require './index'

argv = new Bebopt()
  .define('help::', '\tprint this message and exit', () ->
    @printHelp()
    process.exit(0)).alias('h')
  .define('version', '\tprint program version and exit', () ->
    console.log('1.0')
    process.exit(0)).alias('v', 'ver')
  .define('x', '\t\tblah', () ->
    @log(@))
  .parse()

console.log argv
