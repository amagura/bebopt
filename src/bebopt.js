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

var util = require('util')
  , clone     = require('clone')
  , basename  = require('path').basename
  ;

// functions that don't need to be part of the Bebopt object >>>1
function separateOptionsFromArgs(opt) {
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
}

function sanitizeContext(cb) {
  cb.apply(self, []);
}

function makeOption(name) {
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
}

function gatherArgs(args) {
  var optend = false
    , args = []
    , opts = []
    , argv = args ||
      (process.argv.length === 1 ? process.argv.slice(1) : process.argv.slice(2))
    ;
  argv.forEach(function(arg, ind, arr) {
    if (/^--$/.test(arg))
      optend = true;
    else
      if (optend || /^[^-]+/.test(arg)) {
        args.push({
          arg: arg,
          index: ind
        });
      } else {
        var new_opt = separateOptionsFromArgs(arg);
        opts.push({
          arg: new_opt.opt,
          optarg: new_opt.arg,
          index: ind
        });
      }
  });
  return [
    args,
    opts
  ];
}

function log(obj) { // XXX for debugging only
  console.log(util.inspect(obj, { colors: true, depth: null }));
}

function runCallbacks(parent) {
  var self = this
    , arg
    ;

  parent._cooked.forEach(function(option) {
    arg = option.cb.apply(self, [ option.arg ]);
    parent._results[option.name] = {
      before: option.arg, // arg before Cb
      after: arg // arg after Cb
    };
  });
  return parent._results;
}


function SanitaryContext() {
  this.usage = this.usage === null ? undefined : this.usage;
  this.app;
  this.help;
  this.log = log;
}

SanitaryContext.prototype.printHelp = function(cb) {
  var self = this
    , cb = (cb === undefined ? console.error : cb)
    , usage = (self.usage === undefined ? 'Usage: ' + self.app.toString() : self.usage)
    ;

  cb(usage);
  self.help.forEach(function(txt) { cb(txt); });
};

// <<<1
function Bebopt(app) {
  this.app = app ||
    (process.argv.length === 1) ? 'node' : basename(process.argv[1]);
  this._usage = 'Usage: ' + this.app.toString();
  this._long = {};
  this._short = {};
  this._children = {};
  this._help = [];
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

Bebopt.prototype.define = function(_name, help, cb) {
  var list = _name.length > 1 ? 'long' : 'short'
    , optInfo = makeOption(_name)
    , name = optInfo.name
    , type = optInfo.opt
    ;

  if (!(cb instanceof Function) && !(help instanceof Function)) {
    var err = 'Bebopt: no callback function found';
    throw new Error(err);
  } else if ((typeof cb !== 'string') && (typeof help !== 'string')) {
    var err = 'Bebopt: no help string found';
    throw new Error(err);
  }

  function _defineOption(name, type, text, cb) {
    var list = name.length > 1 ? 'long' : 'short'
      , index = Object.keys(this['_' + list]).length
      ;

    this['_' + list][name] = {
      name: name,
      cb: cb,
      type: type,
      child: [],
      arg: undefined,
      index: index
    };

    _defineHelp.apply(this, [this['_' + list][name], text]);
  }

  function _defineHelp(optObj, text) {
    var self = this
      , list = optObj.name.length > 1 ? 'long' : 'short'
      , helpObj = {
        text: text,
        child: optObj.child
      };
    helpObj.list = list;
    helpObj.name = optObj.name.length > 1 ? '--' : '-';
    helpObj.name += optObj.name;
    this._help.push(helpObj);
  }

  if (typeof cb === 'string') {
    _defineOption.apply(this, [ name, type, help, cb ]);
  } else {
    _defineOption.apply(this, [ name, type, cb, help ]);
  }
  return this;
};

/* parentName -> keys, childName -> aliases */
Bebopt.prototype.alias = function(parentName, childName) {
  var self = this
    , parents = []
    , children = []
    ;

  if (parentName instanceof Array && childName instanceof Array) {
    if (childName.length !== parentName.length) {
      var err = 'Bebopt: unbalanced keys or aliases: arrays differ in length';
      throw new Error(err);
    }
  } else if (parentName instanceof Array && !(childName instanceof Array)) {
    var err = 'Bebopt: an alias cannot belong to multiple keys';
    throw new Error(err);
  }

  if (parentName instanceof Array) {
    parentName.forEach(function(optname) {
      var list = optname.length > 1 ? 'long' : 'short'
        ;
      parents.push(self['_' + list][optname]);
    });
  } else {
    var list = parentName.length > 1 ? 'long' : 'short'
    parents.push(self['_' + list][parentName]);
  }

  var list = childName.length > 1 ? 'long' : 'short';
  if (childName instanceof Array) {
    childName.forEach(function(cname) {
      children.push({
        name: cname,
        list: list
      });
    });
  } else {
    children.push({
      name: childName,
      list: list
    });
  }

  if (childName instanceof Array) {
    if (parentName instanceof Array) {
      children.forEach(function(child, ind) {
        self._children[child.name] = child;
        parents[ind].child.push(Object.keys(self._children).indexOf(child.name));
      });
    } else {
      children.forEach(function(child) {
        self._children[child.name] = child;
        parents[0].child.push(Object.keys(self._children).indexOf(child.name));
      });
    }
  } else {
    self._children[children[0].name] = children[0];
  }
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

// sep -> separate
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

Bebopt.prototype._resolveOpts = function(args, opts) {
  var self = this;
  opts = self._splitCombinedShorts(opts);
  opts.forEach(function(elem) {
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
  self._eaten['_'] = args;
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

Bebopt.prototype.parse = function(args) {
  this._makeHelp();
  this._resolveOpts(gatherArgs(args));
  var SC = new SanitaryContext.apply({
    help: this._help,
    app: this.app,
    usage: this._usage
  }, []);
  runCallbacks.apply(SC, [{
    _cooked: this._cooked,
    _results: this._results
  }]);
  log(this);
};

module.exports = Bebopt;
