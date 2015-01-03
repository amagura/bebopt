bebopt = require './index'

bebopt = new bebopt()
  .longBeat('help::', () ->
    bebopt.printHelp()
    process.exit(0))
  .shortBeat('h').help('print this message and exit')
  .longBeat('version', () ->
    console.log('1.0')
    process.exit(0))
  .shortBeat('v:').help('print program version and exit')
  .parse()
