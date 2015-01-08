m4_dnl vim:ft=markdown:
m4_include(m4)m4_dnl
# API (v0.2)

### Index
* [Public Methods](WIKI(API#public-methods))
 - [.usage](WIKI(API#usage))

---

# Public Methods
All public methods are guaranteed to return a reference to `this`, or raise an exception on misuse.

## .usage(string)
> Sets the usage-string printed by [printHelp](WIKI(API#printHelp)) to `string`; it is the first thing printed by [printHelp](WIKI(API#printHelp))

#### Example:
```javascript
var argv = Bebopt
  .usage('hello')
  .define('h', '\tprint this message and exit', function() {
      this.printHelp();
      process.exit(0);
  }).parse();
```
##### Output:
```
hello
  -h    print this message and exit
```

## .parse([args])
> Parses `args`, or `process.argv` if `args` is undefined.
Does __not__ _return `this`_; instead `.parse` returns a hash containing an object<sup>&dagger;</sup> for each option found in `args`.

> <sup>&dagger; In the form of: `foobar: { before: 'foo', after: 'bar' }`, where `foo` is the argument supplied to the `--foobar` option, and `bar` is the return value of `foobar`'s callback.</sup>

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
