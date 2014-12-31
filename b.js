// vim:ft=javascript:
var bebopt = require('./bebopt');
var a = new bebopt();
a.long('help', function() {
  console.log('help');
  process.exit(0);
}, 'print this message and exit').long('version', function() {
  console.log('version');
  process.exit(0);
}, 'print program version and exit').short('h', '&long.help');
