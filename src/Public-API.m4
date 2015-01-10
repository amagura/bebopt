m4_dnl vim:ft=markdown:
m4_include(m4)m4_dnl
# VERSION

### Index
* [General Use](WIKI(Public-API#general-use))
  - [types](WIKI(Public-API#types))
* [Public Methods](WIKI(Public-API#public-methods))
 - [.usage](WIKI(Public-API#this--usagestring))
 - [.parse](WIKI(Public-API#hash--parseargs))
 - [.define](WIKI(Public-API#this--definename-help-text-callback))
   - [Long Options](WIKI(Public-API#long-options))
    - [Short Options](WIKI(Public-API#short-options))
 - [.alias](WIKI(Public-API#this--aliasaliases))
* [Callback Methods](WIKI(Public-API#callback-methods))
  - [printHelp](WIKI(Public-API#undefined--printhelpcb))
  - [log](WIKI(PUBLIC-API#undefined--log))

---

# General Use
GNU C getopt style options are fully supported by Bebopt.

Both long and short options may receive arguments in both implicit and explicit forms.

* explicit: `--help=<ARG>, --help <ARG>`
* implicit: `-h <ARG>, -h=<ARG>`

#### NOTE
Flag options may only receive an argument in the explicit form: `<FLAG>=<ARG>`, which produces an error, since the value of a flag is determined by how many times it appears on the command-line, and so cannot be set using an argument.

Passing an argument to a flag in the implicit form (e.g. `<FLAG> <ARG>`) has no effect and does not produce an error.  The flag simply ignores the argument and Bebopt treats said argument as a positional argument; an example of a positional arg would be the name of a file passed to the `cat` program (e.g. `cat FILENAME`).

## Options
Information regarding some less obvious points about option definitions.

### Callbacks
An option's callback gets called when said option or one of its aliases appears on the command-line.  Any arguments to said option will be available in said option's callback as its first parameter.

The value of this parameter depends on the said option's type:

* a number denoting the times said option was passed to the program (flags)
* a string containing the argument, if any, passed to the option.

After an option's callback returns, the return value is stored in the `after` field under the option's name in the resulting hash that [.parse](WIKI(Public-API#hash--parseargs)) produces.

### Types
There are, so far, 3 types of options:

1. Boolean flags
2. options with optional arguments
3. options with required arguments

An option's type is determined by the opcode, if any, that appears at the end of its name.

#### Flags
No opcode is necessary.  All options are flags by default.

If the option is found _with_ an argument, your program will exit non-zero and print out an error message.

#### Optargs
Appending `::` to the end of an option's name denotes that it accepts an _optional_ argument.

If the option is found without any arguments, the parameter passed to the option's callback will be `undefined`.

#### Args
Appending `:` to the end of an option's name denotes that it accepts a _required_ argument.

If the option is found without any arguments, your program will exit non-zero and print out an error message.

# Public Methods

## _`this`_ &larr; .usage(string)
Sets the usage-string printed by [printHelp](WIKI(Public-API#undefined--printhelpcb)) to `string`; it is the first thing printed by [printHelp](WIKI(Public-API#undefined--printhelpcb))

#### Example:
```javascript
BEBOP_START
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

## *`undefined`* &larr; log(...)
If given a single argument, log will print the output of `util.inspect(ARG)` to _stdout_; when multiple arguments are present, log prints the even ones to _stdout_ using `process.stdout.write()`, and then inspects the odd ones as expected.

EXAMPLE()
```javascript
BEBOP_START
  .usage('hello')
  .define('i', 'blah', function(i) {
      this.log(i);
  })
  .parse(['-i']);
```
OUTPUT()
```javascript
1 // boolean flag `-i' appeared one time
```
