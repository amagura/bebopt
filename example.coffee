bebopt = require './index'

bebopt = new bebopt()
  .longBeat('help::', () ->
    bebopt.printHelp()
    process.exit(0))
  .halfBeat('help')
  .shortBeat('h').help('print this message and exit')
  .longBeat('version', () ->
    console.log('1.0')
    process.exit(0))
  .halfBeat('version')
  .shortBeat('v:').help('print program version and exit')
