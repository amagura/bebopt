#!/usr/bin/env coffee
Bebopt = require './index'

argv = new Bebopt()
  .longOption('help::', () ->
    @printHelp()
    process.exit(0))
  .shortOption('h').help('\tprint this message and exit')
  .longOption('version', () ->
    console.log('1.0')
    process.exit(0))
  .shortOption('v').help('\tprint program version and exit')
  .shortOption('x', () ->
    @).help('\t\tblah')
  .parse()

console.log argv
