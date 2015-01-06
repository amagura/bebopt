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
  , basename  = require('basename')
  ;

function Bebopt(app) {
  this.app = app ||
    (process.argv[1] === undefined) ? 'node' : basename(process.argv[1]);
  this._options = [];
  this._parent = null;
  this._raw = process.argv;
  this._cooked = [];
  this._eaten = {};
  this.usage = undefined;
  this._help = [];
}

Bebopt.prototype._beatError = function(parent, name) {
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
    , new_name = name.replace(/^(.*?)[:]*$/, '$1');
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

Bebopt.prototype._extend = function(name, cb) {
  this.prototype[name] = cb;
  return this;
};

Bebopt.prototype._makeBeat = function(list) {
  return function(context, _name, fn) {
    var self = context
      , _ref = self._makeOpt(_name)
      , name = _ref.name
      , op = _ref.op
      ;

    // make sure that the desired option-name is valid
    self._beatError(list, name);

    // if function isn't defined, then
    // we are working with a reference to a parent option
    if (fn === undefined) {
      self._parent.type = self._parent.type || op;
      // clone is necessary so that we can set things without them
      // carrying over to the parent option
      child = clone(self._parent);

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
      option = self._options.pop(); // NOTE makes `options.length` 1 less
      option.index = self._options.length;
      self._options.push(option);
    }
    self._parent = self._options.slice(-1)[0];
    return self;
  };
};

Bebopt.prototype.longBeat = function(name, fn) {
  return this._makeBeat('long')(Bebopt, name, fn);
};

Bebopt.prototype.help = function(text) {
  if (this._parent === null) {
    var err = 'Bebopt: null parent ref: cannot apply';
    throw new Error(err);
  }
  this._parent.usage = text;
  this._parent = null;
  return this;
};

Bebopt.prototype.usage = function(text) {
  this.usage = text;
  return this;
};

Bebopt.prototype._makeHelp = function() {
  var self = this;
  this._options.forEach(function(opt) {
    var dashes = (opt.list === 'short') ? '-' : '--'
      , usage = self._parentOrChildUsage(opt);
    self._help.push(self._hasChild(
          opt,
          ('  ' + dashes + opt.name + usage),
          ('  ' + (dashes === '--'
                   ? '-' + opt.child.name + ', ' + dashes + opt.name + usage
                   : dashes + opt.name + ', --' + opt.child.name + usage)),
          ''));
  });
};

Bebopt.prototype._parentOrChildUsage = function(opt) {
  var self = this;
  if (typeof(opt.usage) !== 'string') {
    return this._hasChildParent(
      opt,
      '',
      self._options[opt.child.index].usage,
      self._options[opt.parent.index].usage,
      self._options[opt.parent.index].usage);
  } else {
    return opt.usage;
  }
};

Bebopt.prototype.printHelp = function(fn) {
  var self = this
    , fn = (fn === undefined ? console.error : fn)
    , usage = (self.usage === undefined ? 'Usage: ' + self.app.toString() : self.usage);

  fn(usage);
  self._help.forEach(function(txt) {
    fn(txt);
  });
};

Bebopt.prototype.__hasChildParent = function(opt, noneCb, childCb, parentCb, bothCb) {
  if (opt.child === null) {
    if (opt.parent === null) {
      return noneCb(false, false);
    } else {
      return parentCb(false, true);
    }
  } else {
    if (opt.parent === null) {
      return childCb(true, false);
    } else {
      return bothCb(true, true);
    }
  }
};

Bebopt.prototype._hasChildParent = function(opt, none, child, parent, both) {
  return this.__hasChildParent(opt,
    function() { return none; },
    function() { return child; },
    function() { return parent; },
    function() { return both; });
};

Bebopt.prototype._hasChild = function(opt, none, child, parent) {
  return this.__hasChildParent(opt,
    function() { return none; },
    function() { return child; },
    function() { return parent; },
    function() { return child; });
};

// sep -> separate
Bebopt.prototype._sepOptArg = function(opt) {
  var arg, _opt;
  if (/=/.test(opt)) {
    arg = opt.replace(/.*?=(.*)/, '$1');
  } else {
    arg = undefined;
  }
  _opt = opt.replace(/(.*)?=.*/, '$1');
  return {
    opt: _opt,
    arg: arg
  };
};
