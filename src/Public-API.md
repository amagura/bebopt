
# Version 0.2.x

### Index
* [Public Methods](https://github.com/amagura/bebopt/wiki/Public-API#public-methods)
 - [.usage](https://github.com/amagura/bebopt/wiki/Public-API#this--usagestring)
 - [.parse](https://github.com/amagura/bebopt/wiki/Public-API#hash--parseargs)
 - [.define](https://github.com/amagura/bebopt/wiki/Public-API#this--definename-help-text-callback)
   - [Long Options](https://github.com/amagura/bebopt/wiki/Public-API#long-options)
    - [Short Options](https://github.com/amagura/bebopt/wiki/Public-API#short-options)
 - [.alias](https://github.com/amagura/bebopt/wiki/Public-API#this--aliasaliases)

---

# Public Methods

## _`this`_ &larr; .usage(string)
Sets the usage-string printed by [printHelp](https://github.com/amagura/bebopt/wiki/API#printHelp) to `string`; it is the first thing printed by [printHelp](https://github.com/amagura/bebopt/wiki/API#printHelp)

#### Example:
```javascript
var argv = new Bebopt
  .usage('hello')
  .define('h', '\tprint this message and exit', function() {
      this.printHelp();
      process.exit(0);
  })BEBOP_END(['-h']);
```
#### Output:
```
hello
  -h    print this message and exit
```

## _`Hash`_ &larr; .parse([args])
Parses `args`, or `process.argv` if `args` is undefined.
The hash returned by `.parse` is of the form:

```
{
  <Option Name>: {
    before: <Option Arg>,
    after: <Value Returned By Option's Callback>
  }
}
```
#### Example 1:
```javascript
var argv = new Bebopt
  .usage('hello')
  .define('h:', '\tfoo', function(){}) // `-h' takes a required arg
  .parse([
    '-h',
    'bar'
  ]);
console.log(argv);
```
#### Output:
```javascript
// the callback didn't return anything: making `after' undefined.
{ h: { before: 'bar', after: undefined }}
```
#### Example 2:
```javascript
var argv = new Bebopt
  .usage('hello')
  .usage('hello')
  .define('h:', '\tfoo', function(){ return true; })
  .parse([
    '-h',
    'bar'
  ]);
console.log(argv);
```
#### Output:
```javascript
// the callback returned `true'.
{ h: { before: 'bar', after: true }}
```

## _`this`_ &larr; .define(name, help-text, callback)
defines an option named `name`.

The following `name` suffixes have special meanings:
* `:` &rarr; option accepts a required argument
* `::` &rarr; option accepts an optional argument
* `<no suffix>` &rarr; option does not accept any arguments; defaults to true when present, and false when absent.

The `help-text` and `callback` args can be passed in any order, so long as they come after `name`.

#### Short Options
Short options are limited to single character names.  (e.g. `h`, `v`)
```javascript
.define('h', 'foobar', function(){}); // defines `-h'
```

#### Long Options
Long options are limited to multi-character names. (e.g. `help`, `version`)
```javascript
.define('help', 'foobar', function(){}); // defines `--help'
```

## *`this`* &larr; .alias(aliases)
define aliases for an immediately preceding option definition.

##### NOTE
calling `.alias` without prefacing it with an option defintion will raise an exception.
#### Example:
```javascript
var argv = new Bebopt
  .usage('hello')
  .define('h', '\tfoo', function(){})
  .alias('help')
  .parse(['--help'])
```
#### Output:
```
hello
  foo
```
