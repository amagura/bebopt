# API (v0.2)
changequote(``'', ```''')
define(`'WIKI``'', `'https://github.com/amagura/bebopt/wiki``'')

### Index
* [Public Methods](https://github.com/amagura/bebopt/wiki/API#public-methods)

---

# Public Methods
All public methods are guaranteed to return a reference to `this`, or raise an exception on misuse.

## .usage(string)
> Sets the usage-string printed by [printHelp]( to `string`; it is the first thing printed by [printHelp](https://github.com/amagura/bebopt/wiki/API#printHelp)

#### Example:
```javascript
var argv = Bebopt
  .usage('hello')
  .define('h', '\tprint this message and exit', function() {
      this.printHelp();
      process.exit(0);
  }).parse();
```
##### Output
```
hello
  -h    print this message and exit
```
