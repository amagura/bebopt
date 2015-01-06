#!/usr/bin/env coffee
Bebopt = require './index'

argv = new Bebopt()
  .lO('help::', () ->
    @printHelp()
    process.exit(0))
  .sO('h', '\tprint this message and exit')
  .lO('version', () ->
    console.log('1.0')
    process.exit(0))
  .sO('v', '\tprint program version and exit')
  .sO('x', '\t\tblah', () ->
    @_log(@))
  .parse()

console.log argv
