# Bebopt [![Build Status](https://travis-ci.org/amagura/bebopt.svg?branch=master)](https://travis-ci.org/amagura/bebopt)
a more powerful option parser for node.js

# Why another option parser?
Because so many parsers in node.js either have implementation problems or require boiler-plate code.

## The problem
### Dysfunctional Implementations
Take [optimist](https://github.com/substack/node-optimist) and [yargs](https://github.com/chevex/yargs), for example: both of them are great parsers in their own right, but they provide no method or abstraction for handling arguments _in the order in which they_ appear _on the command-line_.

Instead, the way I've seen most people use both of these excellent parsers inherently makes their programs handle args in the order in which they are handled:

```javascript
#!/usr/bin/env node
// ex.js
// an example of optimist in action
var args = require('optimist')
    .usage('Do stuff')
    .describe('h', 'print this message and exit')
    .describe('v', 'print program version and exit')
    .argv;

if (args.v)
  console.log('1.0');
  process.exit(0);
if (args.h)
  args.showHelp();
  process.exit(0);
```

Because `-v` is handled before `-h`; so even if you run `node ex.js -h -v`, the version string will always get printed _instead_ of the expected usage information.

***

In optimist, the problem can _sort of_ be resolved by looping over the resulting `args` object using `Object.key` like so:

```javascript
#!/usr/bin/env node
// ex.js
// an example of optimist in action
var args = require('optimist')
    .usage('Do stuff')
    .describe('h', 'print this message and exit')
    .describe('v', 'print program version and exit')
    .argv;

// doesn't capture commands
// can also be done in a really ugly way like so:
// Object.keys(args).slice(Object.keys(args).indexOf('$0') + 1)
Object.keys(args).slice(2).forEach(function(key) {
  /* process args using a switch */
});
```
I say _sort of_ because the above solution doesn't capture [commands](https://github.com/substack/node-optimist#and-non-hypenated-options-too-just-use-argv_), is ugly, and [_doesn't_ work](https://github.com/chevex/yargs/issues/39) with yargs!!

Optimist, at least, has other problems as well: such as flag options (i.e. options that do not take args) being defined as either `true` or `false` depending on whether or not they appear on the command-line.  However, most of these are related to the _main_ problem I've already described.

### Boiler-plate Code
[node

## The solution
### The abstraction is too weak
Bebopt addresses the problems present in parsers like _optimist_ and _yargs_, by:
* handling options as they are received on the command-line (i.e. `-h -v` -> `-h` will always be processed first)
* the resulting object produced by Bebopt only contains options that appeared on the command-line

### The abstraction is too verbose
Bebopt's API requires little more, in the way of lines of code, than _optimist_'s API.  Except that Bebopt's API shouldn't require _any_ additional option handling.

#### Optimist
```javascript
var args = require('optimist')
    .usage('Do stuff')
    .describe('h', 'print this message and exit')
    .describe('v', 'print program version and exit')
    .argv;
/* still gotta write handler functions
i.e. `if (args.h) args.showHelp();'
*/
```

#### Bebopt
```javascript
var bebopt = require('bebopt');

var args = bebopt(null, 'abbrev')
    .us('Do Stuff')
    .sO('h', function () { this.pHp; process.exit(0); }, '\tprint this message and exit')
    .sO('v', function () { console.log('1.0'); process.exit(0); }, '\tprint program version and exit')
    .parse();
```
