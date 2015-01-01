'use strict';

var winston = require('winston')
  , inspect = require('util').inspect
  ;

function Logger() {
  this.app = this.app || undefined;
  this.log = this.log || 'silly';
  this.levels = {};
  this.colors = {};
  var self = this
    , idx = 0;
  [
    [ 'status', 'light blue zebra' ],
    [ 'silly', 'rainbow' ], // level-name, level-color
    [ 'verbose', 'magenta' ],
    [ 'debug', 'yellow' ],
    [ 'info', 'blue' ],
    [ 'warn', 'red' ],
    [ 'error', 'red' ],
    [ 'GAMEOVER', 'blackBG bold white' ]
  ].forEach(function(lvl) {
    self.levels[lvl[0]] = ++idx;
    self.colors[lvl[0]] = lvl[1];
  });

  var lumberjack = new (winston.Logger)({
    levels: self.levels,
    colors: self.colors,
    rewriters: [
      function meta(level, msg, meta) {
        meta = meta || {};
        if (self.app)
          meta.app = self.app;
        return meta;
      }
    ]
  });
  lumberjack.add(winston.transports.Console, {
    level: self.log,
    colorize: true,
  });

  // collect log levels, this is only necessary when using rewriters
  this._vanilla = {};
  Object.keys(lumberjack.levels).forEach(function(key) {
    self._vanilla[key] = lumberjack[key];
  });
  this._silentErrors = true;
  this._logger = lumberjack;
  this._parent = self;
  return this;
}

Logger.prototype.set = function(hash) {
  var self = this;
  Object.keys(hash).forEach(function(key) {
    self._parent[key] = hash[key];
  });
  return this;
};

Logger.prototype.unsetApp = function() {
  this.set({ app: undefined });
  return this;
};

Logger.prototype.setApp = function(app) {
  var self = this;
  app = app || 'node.js';
  self.set({ app: app });
  return this;
};

Logger.prototype.setLoudErrors = function() {
  var self = this;
  self.set({ _silentErrors: !self._silentErrors });
  return this;
};


Logger.prototype.debug = function(y, depth) {
  var self = this;
  self._vanilla['debug'](inspect(y, {colors: true, depth: depth}));
};

function logger() {
  var self = new Logger();

  // add error handling to log levels
  Object.keys(self._logger.levels).forEach(function(key) {
    self._logger[key] = function(msg, meta) {
      if (msg instanceof Error) {
        return self._vanilla[key](msg.stack, meta || {});
      }
      return self._vanilla[key](msg, meta || {});
    };
  });

  // add `setApp' and `set' to self._logger
  [ /*'_vanilla',*/ '_parent', 'setApp', 'set' ].forEach(function(meth) {
    self._logger[meth] = self[meth];
  });
  return self._logger;
}

module.exports = logger();
