/***
Copyright 2015 Alexej Magura

This file is part of TexSys

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
var spawn       = require('child_process').spawn
  , eol         = require('os').EOL
  , clone       = require('clone')
  , stewardess  = require('stewardess')
  , waitress    = require('waitress')
  , u     = require('underscore')
  ;

function TexSys(app) {
  this.app = this.app || app || null;
  this.args = this.args || [];
  this.child = this.child || {};
  return this;
}

TexSys.prototype._makeArgs = function() {
  var self = this;
  self.cmd = self.cmd.split(' ')[0];
  self.args = self.cmd.split(' ').slice(1);
};

TexSys.prototype._findCb = function(opts, cb) {
  this.cb = (cb) ? cb : opts;
  this.opts = (cb) ? opts : {};
  return this;
};

TexSys.prototype.run = function(cmd) {
  var self = this;
  self.cmd = cmd;
  self._makeArgs();

