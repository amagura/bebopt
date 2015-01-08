m4_dnl vim:ft=markdown:
m4_include(m4)m4_dnl
# API (v0.2)

### Index
* [Public Methods](WIKI(API#public-methods))
 - [.usage](WIKI(API#usage))

---

# Public Methods

## .usage(string) &rarr; `this`
> Sets the usage-string printed by [printHelp](WIKI(API#printHelp)) to `string`; it is the first thing printed by [printHelp](WIKI(API#printHelp))

#### Example:
```javascript
var argv = Bebopt
  .usage('hello')
  .define('h', '\tprint this message and exit', function() {
      this.printHelp();
      process.exit(0);
  }).parse(['-h']);
```
#### Output:
```
hello
  -h    print this message and exit
```

## .parse([args]) &rarr; `Hash`
> Parses `args`, or `process.argv` if `args` is undefined.
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
var argv = Bebopt
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
var argv = Bebopt
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
