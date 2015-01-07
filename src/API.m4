# API (v0.2)

### Index
* [Public Methods](WIKI(API#public-methods))

---

# Public Methods
All public methods are guaranteed to return a reference to `this`, or raise an exception on misuse.

## .usage(string)
> Sets the usage-string printed by [printHelp]( to `string`; it is the first thing printed by [printHelp](WIKI(API#printHelp))

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
