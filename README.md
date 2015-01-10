# Bebopt [![Build Status](https://travis-ci.org/amagura/bebopt.svg?branch=master)](https://travis-ci.org/amagura/bebopt)
a more powerful option parser for node.js

#### NOTE
If you're looking for documentation, please refer to the [wiki](https://github.com/amagura/bebopt/wiki/Public-API).

# Why another option parser?
Because I'm tired of using option parsers that don't do their jobs very well.
Nearly every parser I've used has required either a workaround to make it work _correctly_ or boilerplate code that seems to scare some developers, but shouldn't be required anyway.  In short: untraditional implementations and poor abstractions.

## Some examples
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
