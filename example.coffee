#!/usr/bin/env coffee
Bebopt = require './index'

argv = new Bebopt(null, 'abbrev')
  .lO('help::', () ->
    @pHp()
    process.exit(0))
  .sO('h').help('\tprint this message and exit')
  .lO('version', () ->
    console.log('1.0')
    process.exit(0))
  .sO('v').help('\tprint program version and exit')
  .sO('x', () ->
    @).help('\t\tblah')
  .parse()

console.log argv
