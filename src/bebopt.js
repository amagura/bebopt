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

function rev_uniq(arr) {
  var seen = Object.create(null)
    , out = []
    , len = arr.length
    , jdx = 0;

  for(var idx = 0; idx < len; ++idx) {
    var item = arr.reverse()[idx];
    item = (item instanceof Function) ? item.toString() : item;
    if(seen[item] !== 1) {
      seen[item] = 1;
      out[jdx++] = item;
    }
  }

  return out;
}

function makeOption(name) {
  var new_op = name.replace(/^.*?([:]*)$/, '$1')
    , new_name = name.replace(/^(.*?)[:]*$/, '$1')
    , op
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
    type: op,
    name : new_name
  };
}

function syncIndexes(arr, threshold) {
  arr.forEach(function(elem) {
    elem.index >= threshold && ++elem.index;
  });
  return arr;
}

function filterNull(map) {
  var arr;
  arr = (map instanceof Array
        ? map : Object.keys(map));

  return arr.filter(function(elem) {
    if (map instanceof Array)
      return elem !== null;
    else
      return map[elem] !== null;
  });
}

function log(obj) { // XXX for debugging only
  console.log(util.inspect(obj, { colors: true, depth: null }));
}

function runCallbacks(parent) {
  var self = this
    , arg
    ;

  parent._cookedArgs.forEach(function(option) {
    arg = option.cb.apply(self, [ option.arg ]);
    parent._servedArgs[option.name] = {
      before: option.arg, // arg before Cb
      after: arg, // arg after Cb
      index: option.cli_index
    };
  });
  return parent._servedArgs;
}

function Bebopt(app) {
  this.app = app ||
    (process.argv.length === 1) ? 'node' : basename(process.argv[1]);
  this._usage = 'Usage: ' + this.app.toString();
  this._long = {};
  this._short = {};
  this._help = [];
  this.help = [];
  this._thawedArgs = [];
  this._cookedArgs = [];
  this._servedArgs = {};
  this._rawArgs = {
    args: [],
    opts: []
  };
  this._parent = null;
}

Bebopt.prototype.define = function(_name, help, cb) {
  var list = _name.length > 1 ? 'long' : 'short'
    , optInfo = makeOption(_name)
    , name = optInfo.name
    , type = optInfo.type
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
      index: index,
      list: list
    };

    _defineHelp.apply(this, [this['_' + list][name], text]);
    return this['_' + list][name];
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
    this._parent = _defineOption.apply(this, [ name, type, cb, help ]);
  } else {
    this._parent = _defineOption.apply(this, [ name, type, help, cb ]);
  }
  return this;
};

Bebopt.prototype.alias = function() {
  var self = this
    , aliases = (arguments.length > 0 && arguments.length < 2
                ? [arguments[0]]
                : Array.apply(null, arguments));

  if (self._parent === null || self._parent === undefined) {
    var err = 'Bebopt: call to define must precede';
    throw new Error(err);
  } else if (!(aliases instanceof Array)) {
    var err = 'Bebopt: no aliases found';
    throw new Error(err);
  }

  aliases.forEach(function(aname) {
    var list = aname.length > 1 ? 'long' : 'short';
    self._parent.child.push({
      name: aname,
      list: list
    });
  });
  self._parent = null;
  return this;
};

Bebopt.prototype.usage = function(text) {
  this._usage = text;
  return this;
};

Bebopt.prototype.printHelp = function(cb) {
  var usage;
  cb = (cb === undefined || cb === null) ? console.error : cb;
  usage = (this.usage === undefined) ? 'Usage: ' + this.app.toString() : this.usage;

  cb(usage);
  this.help.forEach(function(txt) { cb(txt); });
};


Bebopt.prototype._makeHelp = function() {
  var self = this
    , text
    ;
  function _addChildren(helpObj, ctl) {
      var _long, _short, text;
      text = [];

      if (ctl === undefined || ctl === false) {
        _short = helpObj.child
        .filter(function(child) {
          return child.list === 'short';
        });
        _short.forEach(function(child) {
          text.push('-' + child.name);
        });
      } else if (ctl === undefined || ctl === true) {
        _long = helpObj.child
        .filter(function(child) {
          return child.list === 'long';
        });

        _long.forEach(function(child) {
          text.push('--' + child.name);
        });
      }
    return text;
  }

  this._help.forEach(function(helpObj) {
    text = '  ';
    if (helpObj.list === 'short') {
      text += helpObj.name;
      if (helpObj.child.length > 0) {
        _addChildren(helpObj).forEach(function(txt) {
          text += ', ' + txt;
        });
      }
    } else {
      if (helpObj.child.length > 0) {
        _addChildren(helpObj, false).forEach(function(txt) {
          text += txt + ', ';
        });

        text += helpObj.name

        _addChildren(helpObj, true).forEach(function(txt) {
          text += ', ' + txt;
        });
      } else {
        text += helpObj.name;
      }
    }
    self.help.push(text);
  });
  delete self._help;
};

Bebopt.prototype._bindCli = function(cli, list) {
  var self = this
    , option
    ;

  var option = this._getOption(cli, list);

  switch (option.type) {
    case 'arg':
      if (cli.optarg === undefined) {
        var err = this.app.toString();
        err += (list === 'short'
            ? 'option requires an argument -- \'' + cli.arg + '\''
            : 'option \'--' + cli.arg + '\' requires an argument');
        console.error(err);
        process.exit(1);
      } else {
        option.arg = cli.optarg;
      }
      break;
  case 'optarg':
    option.arg = cli.optarg;
    break;
  case 'flag':
    if (cli.optarg !== undefined) {
      var err = self.app.toString();
      err += (list === 'short'
              ? 'option doesn\'t allow an argument -- \'' + cli.arg + '\''
              : 'option \'--' + cli.arg + '\' doesn\'t allow an argument');
      console.error(err);
      process.exit(1);
    } else {
      option.arg = cli.index + 1;
    }
    break;
  }
  option.cli_index = cli.index;
  return option;
};

Bebopt.prototype._catchInvalids = function(cli, list) {
  var self = this
    , option = this._getOption(cli, list)
    ;

  if (option === undefined) {
    var err = self.app.toString() + ': ';
    if (list === 'short')
      err += 'invalid option -- \'';
    else
      err += 'unrecognized option \'--';
    err += cli.arg + '\'';
    console.error(err);
    process.exit(1);
  }
  return option;
};

Bebopt.prototype._getOption = function(cli, list) {
  var self = this
    , otherList = (list === 'long' ) ? 'short' : 'long'
    , _def
    ;

  for (var def in this['_' + list]) {
    _def = this['_' + list][def];
    if (cli.arg === def && list === _def.list)
      return _def;
    else {
      for (var idx = 0; idx < _def.child.length; ++idx) {
        if (_def.child[idx].name === cli.arg || _def.child[idx].list === list)
          return _def;
      }
    }
  }

  for (var def in this['_' + otherList]) {
    _def = this['_' + otherList][def];
    if (cli.arg === def && list === _def.list)
      return _def;
    else {
      for (var idx = 0; idx < _def.child.length; ++idx) {
        if (_def.child[idx].name === cli.arg || _def.child[idx].list === list)
          return _def;
      }
    }
  }
};

Bebopt.prototype._resolveOpts = function(args, opts) {
  var self = this
    , dashes
    , option
    , ccli
    ;

  this._rawArgs.opts.forEach(function(cli) {
    var list = cli.arg.length > 1 ? 'long' : 'short';
    if (self._catchInvalids(cli, list).type !== 'flag') {
      cli = self._catchSpaceDelimArgs(cli, list);
    }
    ccli = clone(cli);
    ccli.list = list;
    self._thawedArgs.push(ccli);
    self._cookedArgs.push(self._bindCli(cli, list));
  });
  this._cookedArgs = rev_uniq(this._cookedArgs);
  var under = this._servedArgs['_'] = {};
  this._rawArgs.args.forEach(function(elem) {
    under[elem.arg] = {
      index: elem.index
    };
  });
  return this;
};

Bebopt.prototype._catchSpaceDelimArgs = function(cli, list) {
  var self = this
    , option
    ;

  option = this._getOption(cli, list);

  if (option.type !== 'flag' && cli.optarg === undefined) {
    this._rawArgs.args.forEach(function(nonOpt, ind) {
      if (nonOpt.index === (cli.index + 1)) {
        cli.optarg = nonOpt.arg;
        self.args[ind] = null;
      }
    });
    self._rawArgs.args = filterNull(self._rawArgs.args);
  }
  return cli;
};

Bebopt.prototype._splitCombinedShorts = function() {
  var self = this
    , dashes
    ;

  this._rawArgs.opts.forEach(function(elem, ind) {
    dashes = elem.arg.replace(/^(--?).*/, '$1').length;
    if (dashes === 1) {
      var options = elem.arg.replace(/^-(.*)/, '$1').split('');
      options = options.reverse();
      elem.arg = options.pop();

      while (options.length > 0) {
        new_elem = clone(elem);
        new_elem.arg = options.pop();
        if (self._rawArgs.args[new_elem.index] !== undefined) {
          args = syncIndexes(self._rawArgs.args, new_elem.index);
        }
        opts = syncIndexes(self._rawArgs.opts, new_elem.index++);
        opts.push(new_elem);
      }
    }
  });
  return this;
};

Bebopt.prototype._gatherArgs = function(args) {
  var self = this
    , optend
    , argv = args ||
      (process.argv.length === 1 ? process.argv.slice(1) : process.argv.slice(2))
    ;

  function _separateOptionsFromArgs(opt) {
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

  argv.forEach(function(arg, ind, arr) {
    if (/^--$/.test(arg))
      optend = true;
    else
      if (optend || /^[^-]+/.test(arg)) {
        self._rawArgs.args.push({
          arg: arg,
          index: ind
        });
      } else {
        var new_opt = _separateOptionsFromArgs(arg);
        self._rawArgs.opts.push({
          arg: new_opt.opt,
          optarg: new_opt.arg,
          index: ind
        });
      }
  });
  return this;
};

Bebopt.prototype.parse = function(args) {
  delete this._parent;
  this._makeHelp();
  this._gatherArgs(args);
  this._splitCombinedShorts();
  this._resolveOpts();
  return runCallbacks.apply({
    printHelp: this.printHelp,
    help: this.help,
    app: this.app,
    usage: this._usage,
    log: log,
    args: {
      thawed: this._thawedArgs,
      cooked: this._cookedArgs
    }
  }, [{
    _cookedArgs: this._cookedArgs,
    _servedArgs: this._servedArgs
  }]);
};

module.exports = Bebopt;
