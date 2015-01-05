Bebopt = require './index'

bebopt = new Bebopt()
  .longBeat('help::', () ->
    @printHelp()
    process.exit(0))
  .shortBeat('h').help('\tprint this message and exit')
  .longBeat('version', () ->
    console.log('1.0')
    process.exit(0))
  .shortBeat('v').help('\tprint program version and exit')
  .shortBeat('x', () ->
    @).help('\tblah')
  .parse()
