#!/usr/bin/env node
'use strict';
function Bebopt() {
  this.app = this.app || 'bebopt';
  this._mode = this.app || 'bebopt';
  this._long = {};
  this._short = {};
  this._shortLong = {};
  this._parent = null;
  return this;
}

(['long', 'short', 'shortLong']).map(function(fn) {
  return Bebopt.prototype[fn] = function(name, body, desc) {
    var self = this;
    if (typeof(body) == 'string') {
      switch(self._fn) {
        case 'short':
            if (/&long/.test(body))
              self['_' + self._fn][name.toString()] = self._long[body.replace(/&long\./, '')];
            else if (/&shortLong/.test(body))
              self['_' + self._fn][name.toString()] = self._shortLong[body.replace(/&shortLong\./, '')];
          break;
        case 'long':
            if (/&short/.test(body))
              self['_' + self._fn][name.toString()] = self._short[body.replace(/&short\./, '')];
            else if (/&shortLong/.test(body))
              self['_' + self._fn][name.toString()] = self._shortLong[body.replace(/&shortLong\./, '')];
            break;
        case 'shortLong':
            if (/&short/.test(body))
              self['_' + self._fn][name.toString()] = self._short[body.replace(/&short\./, '')];
            else if (/&long/.test(body))
              self['_' + self._fn][name.toString()] = self._long[body.replace(/&long\./, '')];
            break;
      }
    } else {
      self['_' + self._fn][name.toString()] = {
        fn: body,
        desc: desc,
        type: 'Flag'
      };
    }
    self._parent = {
      list: '_' + fn.toString(),
      elem: '&' + name.toString()
    };
    return self;
  }
});

Bebopt.prototype.arg = function(arg_content_test) {
  var self = this;
  if (self._parent !== null) {
    self[self._parent.list][self._parent.elem].type = 'arg';
    self[self._parent.list][self._parent.elem].test = arg_content_test;
    self._parent = null;
  }
  return self;
}

Bebopt.prototype.optarg = function(arg_content_test) {
  var self = this;
  if (self._parent !== null) {
    self[self._parent.list][self._parent.elem].type = 'optarg';
    self[self._parent.list][self._parent.elem].test = arg_content_test;
    self._parent = null;
  }
}

module.exports = Bebopt;
