/***
Copyright 2015 Alexej Magura

This file is part of Bebopt (https://github.com/amagura/bebopt)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
***/
'use strict';

var util      = require('util')
  , clone     = require('clone')
  , basename  = require('path').basename
  ;

function Bebopt(app) {
  this.app = app ||
    (process.argv.length === 1) ? 'node' : basename(process.argv[1]);
  this._options = [];
  this._parent = null;
  this._cooked = [];
  this._results = {};
  this._usage = undefined;
  this._help = [];
  this._opts = [];
  this._args = [];
  this._safeContext = [
    '_usage',
    'printHelp',
    '_help',
    '_cooked',
    '_eaten',
    '_log',
    'app'
  ];
}

Bebopt.prototype._beatError = function(listName, name) {
  if (listName === 'short') {
    if (name.length > 1) {
      err = 'Bebopt: option name too long: \'' + name + '\'';
      throw new Error(err);
    }
  }
  return false;
};

Bebopt.prototype._makeOpt = function(name) {
  var new_op = name.replace(/^.*?([:]*)$/, '$1')
    , new_name = name.replace(/^(.*?)[:]*$/, '$1')
    , op = null
    ;

  switch (new_op) {
    case '::':
      op = 'optarg';
      break;
    case ':':
      op = 'arg';
      break;
    default:
      op = 'flag';
      break;
  }
  return {
    op: op,
    name : new_name
  };
};

Bebopt.prototype._extend = function(context, name, cb) {
  context.prototype[name] = cb; // FIXME, should this be `this', or `context'?
  return this;
};

[ 'shortOption', 'longOption' ].forEach(function(funcName) {
  var list = funcName.replace(/Option/, '');
  return Bebopt.prototype._extend(Bebopt, funcName, function(_name, fn) {
    var self = this
      , _ref = self._makeOpt(_name)
      , name = _ref.name
      , op = _ref.op
      ;

    // make sure that the desired option-name is valid
    self._beatError(list, name);

    // if function isn't defined, then
    // we are working with a reference to a parent option
    if (fn === undefined) {
      self._parentError();
      self._parent.type = self._parent.type || op;
      // clone is necessary so that we can set things without them
      // carrying over to the parent option
      var child = clone(self._parent);

      // give the child a 'pointer' to its parent
      child.parent = self._parent;
      //child.parent.index = child.index;
      ++child.index;
      // set the name of `child' to the value of `name'
      child.name = name;
      child.list = list;
      child.arg = undefined; // this field is `ARG` in `--help=(<ARG>)'

      // give parent a pointer to its child
      self._parent.child = child;
      self._options.push(child);
    } else {
      self._options.push({
        cb: fn,
        type: op,
        name: name,
        list: list,
        child: null,
        parent: null,
        arg: undefined
      });
      var option = self._options.pop(); // NOTE makes `options.length` 1 less
      option.index = self._options.length;
      self._options.push(option);
    }
    self._parent = self._options.slice(-1)[0];
    return self;
  });
});

[ 'lO', 'sO' ].forEach(function(funcName) {
  var list = /^sO$/.test(funcName) ? 'short' : 'long';
  return Bebopt.prototype._extend(Bebopt, funcName, function(name, cb, help) {
    var self = this;
    if (typeof(cb) === 'string') {
      if (help instanceof Function) {
        return self[list + 'Option'](name, help).help(cb);
      } else {
        return self[list + 'Option'](name).help(cb);
      }
    } else if (cb instanceof Function) {
      if (typeof(help) === 'string') {
        return self[list + 'Option'](name, cb).help(help);
      } else {
        return self[list + 'Option'](name, cb);
      }
    }
  });
});

Bebopt.prototype.longBeat = clone(Bebopt.prototype.longOption);
Bebopt.prototype.shortBeat = clone(Bebopt.prototype.shortOption);

Bebopt.prototype._parentError = function() {
  if (this._parent === null || this._parent === undefined) {
    var err = 'Bebopt: null parent ref: cannot apply';
    throw new Error(err);
  }
};

Bebopt.prototype.help = function(text) {
  this._parentError();
  this._parent.usage = text;
  this._parent = null;
  return this;
};

Bebopt.prototype.usage = function(text) {
  this._usage = text;
  return this;
};

Bebopt.prototype._makeHelp = function() {
  var self = this;
  this._options.forEach(function(opt) {
    var dashes = (opt.list === 'short') ? '-' : '--'
      , usage = self._parentOrChildUsage(opt);
    if (opt.parent === null) {
      if (opt.child === null) {
        self._help.push('  ' + dashes + opt.name + usage);
      } else {
        if (dashes === '--')
          self._help.push('  -' + opt.child.name + ', ' + dashes + opt.name + usage);
        else
          self._help.push('  ' + dashes + opt.name + ', --' + opt.child.name + usage);
      }
    }
  });
};

Bebopt.prototype._parentOrChildUsage = function(opt) {
  var self = this;
  if (typeof(opt.usage) !== 'string') {
    if (opt.child === null) {
      if (opt.parent === null)
        return ''; // if both are null
      else
        return self._options[opt.parent.index].usage; // if only child is null
    } else {
      if (opt.parent === null)
        return self._options[opt.child.index].usage;
      else
        return self._options[opt.parent.index].usage;
    }
  } else {
    return opt.usage;
  }
};

Bebopt.prototype.printHelp = function(fn) {
  var self = this
    , fn = (fn === undefined ? console.error : fn)
    , usage = (self._usage === undefined ? 'Usage: ' + self.app.toString() : self._usage)
    ;
  
  fn(usage);
  self._help.forEach(function(txt) {
    fn(txt);
  });
};

// sep -> separate
Bebopt.prototype._sepOptArg = function(opt) {
  var arg, _opt;
  if (/=/.test(opt))
    arg = opt.replace(/.*?=(.*)/, '$1');
  else
    arg = undefined;
  _opt = opt.replace(/(.*)?=.*/, '$1');
  return {
    opt: _opt,
    arg: arg
  };
};

Bebopt.prototype._catchSpaceDelimArgs = function(opt, list) {
  var self = this
    , type = this._getOption(opt, list).type
    ;
  if (type !== 'flag' && opt.optarg === undefined) {
    self._args.forEach(function(nonOpt, ind) {
      if (nonOpt.index === (opt.index + 1)) {
        opt.optarg = nonOpt.arg;
        delete self._args[ind]
      }
    });
  }
  return opt;
};

Bebopt.prototype._catchInvalidOpt = function(opt, list) {
  var self = this
    , option = this._getOption(opt, list)
    ;
  if (list === 'short' && option === undefined) {
    console.error(app.toString() + ': invalid option -- \'' + opt.arg + '\'');
    process.exit(1);
  } else if (list === 'long' && option === undefined) {
    console.error(app.toString() + ': unrecognized option \'--' + opt.arg + '\'');
    process.exit(1);
  }
};

// threshold is the lowest value to be incremented
Bebopt.prototype._syncIndexes = function(list, threshold) {
  list.forEach(function(elem) {
    if (elem.index >= threshold)
      ++elem.index;
  });
  return list;
};

Bebopt.prototype._getOption = function(opt, listName) {
  var self = this;
  var option = self._options.filter(function(mem) {
    if (opt.arg === mem.name && listName === mem.list)
      return mem;
  });
  return (option.length === 0 ? undefined : option[0]);
};

Bebopt.prototype._setOptionArg = function(opt, listName) {
  var self = this
    , option = self._getOption(opt, listName)
    ;

  option.arg = opt.optarg;
  if (option.child !== null)
    self._options[option.child.index].arg = opt.optarg;
  else if (option.parent !== null)
    self._options[option.parent.index].arg = opt.optarg;
  return undefined;
};

Bebopt.prototype._splitCombinedShorts = function() {
  var self = this;
  self._opts.forEach(function(elem, ind) {
    var dashes = elem.arg.replace(/^(--?).*/, '$1').length; // number of dashes
    if (dashes === 1) {
      var options = elem.arg.replace(/^-(.*)/, '$1').split('');
      options = options.reverse();
      elem.arg = options.pop();

      while (options.length > 0) {
        new_elem = clone(elem);
        new_elem.arg = options.pop();
        if (self._args[new_elem.index] !== undefined) {
          self._syncIndexes(self._args, new_elem.index);
        }
        self._syncIndexes(self._opts, new_elem.index + 1);
        ++new_elem.index;
        self._opts.push(new_elem);
      }
    }
  });
};

Bebopt.prototype._takesArg = function(opt, listName) {
  var self = this;
  self._catchInvalidOpt(opt, listName);
  var type = self._getOption(opt, listName).type;
  if (type !== 'flag')
    return true;
  else
    return false;
};

Bebopt.prototype._log = function(xyz) {
  console.log(util.inspect(xyz, { colors: true, depth: null }));
};

Bebopt.prototype._resolveOpts = function() {
  var self = this;
  self._splitCombinedShorts();
  self._opts.forEach(function(elem) {
    var dashes = elem.arg.replace(/^(--?).*/, '$1').length; // number of dashes
    elem.arg = elem.arg.replace(/^--?(.*)/, '$1');
    [
      [ 'long', 2 ],
      [ 'short', 1 ]
    ].forEach(function(arr) {
      if (dashes === arr[1]) {
        if (self._takesArg(elem, arr[0])) {
          elem = self._catchSpaceDelimArgs(elem, arr[0])
        }
        self._bindOptToList(elem, arr[0]);
        var option = self._getOption(elem, arr[0]);
        self._cooked.push(option);
      }
    });
  });
};

Bebopt.prototype._bindOptToList = function(opt, listName) {
  var self = this
    , type = self._getOption(opt, listName).type
    ;

  if (type === 'arg') {
    if (opt.optarg === undefined) {
      var err = self.app.toString();
      err += (listName === 'short'
              ? 'option requires an argument -- \'' + opt.arg + '\''
              : 'option \'--' + opt.arg + '\' requires an argument');
      console.error(err);
      process.exit(1);
    } else {
      self._setOptionArg(opt, listName);
    }
  } else if (type === 'optarg') {
    self._setOptionArg(opt, listName);
  } else if (type === 'flag') {
    if (opt.optarg !== undefined) {
      var err = self.app.toString();
      err += (listName === 'short'
              ? 'option doesn\'t allow an argument -- \'' + opt.arg + '\''
              : 'option \'--' + opt.arg + '\' doesn\'t allow an argument');
      console.error(err);
      process.exit(1);
    } else {
      self._setOptionArg(opt, listName);
    }
  }
};

Bebopt.prototype._gather = function() {
  var self = this
    , optend = false
    , noOpt = false
    ;
  process.argv.slice(2).forEach(function(arg, ind, arr) {
    if (/^--$/.test(arg))
      optend = true;
    else if (/^-$/.test(arg))
      noOpt = true; // prevents `-' from creating an empty option object
      // FIXME, what if people want to read STDIN on `-'?
    else
      if (noOpt) // FIXME, should `!noOpt' be used instead?
        null; // do nothing
      if (optend || /^[^-]+/.test(arg)) { // if optend or no dashes are found
        // then we are working with an non-option argument
        self._args.push({
          arg: arg,
          index: ind
        });
      } else { // else, we are working with an option
        var new_opt = self._sepOptArg(arg);
        self._opts.push({
          arg: new_opt.opt,
          optarg: new_opt.arg,
          index: ind
        });
      }
  });
};

Bebopt.prototype._runCallbacks = function(context) {
  var self = this
    , arg = null
    ;
  this._cooked.forEach(function(option) {
    arg = option.cb.apply(context, [ option.arg ]);
    self._results[option.name] = arg;
    if (option.child !== null) // FIXME this probably will clobber stuff
      self._results[option.child.name] = arg;
    if (option.parent !== null) // FIXME this will probably clobber stuff
      self._results[option.parent.name] = arg;
  });
};

Bebopt.prototype._makeCleanContext = function() {
  var self = this
    , context = clone(self)
    ;
  Object.keys(context).forEach(function(key) {
    if (self._safeContext.indexOf(key) === -1)
      delete context[key];
  });
  return context;
};

Bebopt.prototype.parse = function() {
  this._makeHelp();
  this._gather();
  this._resolveOpts();
  var context = this._makeCleanContext();
  this._runCallbacks(context);
  return this._results;
};

module.exports = Bebopt;
