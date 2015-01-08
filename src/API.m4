m4_dnl vim:ft=markdown:
m4_include(m4)m4_dnl
# Version 0.2

### Index
* [Public Methods](WIKI(API#public-methods))
 - [.usage](WIKI(API#usagestring--this))
 - [.parse](WIKI(API#parseargs--hash))
 - [.define](WIKI(API#definename-help-text-callback--this))
   - [Long Options](WIKI(API#long-options))
    - [Short Options](WIKI(API#short-options))
 - [.alias](WIKI(API#aliaskeys-aliases--this))

---

# Public Methods

## .usage(string) &rarr; `this`
Sets the usage-string printed by [printHelp](WIKI(API#printHelp)) to `string`; it is the first thing printed by [printHelp](WIKI(API#printHelp))

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

## .parse([args]) &rarr; `Hash`
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
&nbsp;
#### Example 1:
```javascript
BEBOP_START
  .define('h:', '\tfoo', function(){}) // `-h' takes a required arg
  .parse([
    '-h',
    'bar'
  ]);
console.log(argv);
```
&nbsp;
#### Output:
```javascript
// the callback didn't return anything: making `after' undefined.
{ h: { before: 'bar', after: undefined }}
```
&nbsp;
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
&nbsp;
#### Output:
```javascript
// the callback returned `true'.
{ h: { before: 'bar', after: true }}
```

## .define(name, help-text, callback) &rarr; `this`
defines an option named `name`.

The following `name` suffixes have special meanings:
* `:` &rarr; option accepts a required argument
* `::` &rarr; option accepts an optional argument
* `<no suffix>` &rarr; option does not accept any arguments; defaults to true when present, and false when absent.

The `help-text` and `callback` args can be passed in any order, so long as they come after `name`.

### Short Options
Short options are limited to single character names.  (e.g. `h`, `v`)
```javascript
.define('h', 'foobar', function(){}); // defines `-h'
```

### Long Options
Long options are limited to multi-character names. (e.g. `help`, `version`)
```javascript
.define('help', 'foobar', function(){}); // defines `--help'
```

## .alias(keys, aliases) &rarr; `this`
defines alias options for option _keys_.

A _key_ may have multiple _aliases_, but an _alias_ cannot be assigned to more than one _key_.

If _keys_ is an array, then _aliases_ should also be an array of equal length, and their contents should occur pairwise. (i.e. `aliases[n]` is assigned to `keys[n]`)

#### Example:
```javascript
BEBOP_START
  BEBOP_DEF
  .alias('help', 'h')
  .parse(['--help'])
```
#### Output:
```
foo
```
