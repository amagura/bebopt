m4_dnl vim:ft=markdown:
m4_include(m4)m4_dnl
# VERSION

### Index
* [Public Methods](WIKI(Public-API#public-methods))
 - [.usage](WIKI(Public-API#this--usagestring))
 - [.parse](WIKI(Public-API#hash--parseargs))
 - [.define](WIKI(Public-API#this--definename-help-text-callback))
   - [Long Options](WIKI(Public-API#long-options))
    - [Short Options](WIKI(Public-API#short-options))
 - [.alias](WIKI(Public-API#this--aliasaliases))
* [Callback Methods](WIKI(Public-API#callback-methods))
  - [printHelp](WIKI(Public-API#undefined--printhelpcb))

---

# Public Methods

## _`this`_ &larr; .usage(string)
Sets the usage-string printed by [printHelp](WIKI(Public-API#undefined--printhelpcb)) to `string`; it is the first thing printed by [printHelp](WIKI(Public-API#undefined--printhelpcb))

#### Example:
```javascript
BEBOP_START
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
EXAMPLE(1)
```javascript
BEBOP_START
  .define('h:', '\tfoo', function(){}) // `-h' takes a required arg
  .parse([
    '-h',
    'bar'
  ]);
console.log(argv);
```
OUTPUT()
```javascript
// the callback didn't return anything: making `after' undefined.
{ h: { before: 'bar', after: undefined }}
```
#### Example 2:
```javascript
BEBOP_START
  .usage('hello')
  .define('h:', '\tfoo', function(){ return true; })
  .parse([
    '-h',
    'bar'
  ]);
console.log(argv);
```
OUTPUT()
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
EXAMPLE()
```javascript
BEBOP_START
  .usage('hello')
  BEBOP_DEF
  .alias('help')
  .parse(['--help'])
```
OUTPUT()
```
hello
  foo
```

# Callback Methods
Public functions intended to only be used within option callbacks.

## *`undefined`* &larr; printHelp(cb)
prints program usage, followed by the help text for each option defined.

see [usage](WIKI(Public-API#this--usagestring)) for an example.
