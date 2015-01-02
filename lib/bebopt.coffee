###
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
###
'use strict'

util = require 'util'

class Bebopt
  constructor: (@app) ->
    @app ?= 'bebopt'
    @_long = {}
    @_short = {}
    @_half = {}
    @_parent = null
    @__rargs = [] # raw args
    @__pargs = [] # processed args
    @__uargs = {} # user-ready args

  _beatError: (parent, name) ->
    switch parent
      when 'long'
        if name.length < 2
          err = "Bebopt: option name too short -- '#{name}'"
          throw new Error(err)
        return false
      when 'short'
        if name.length > 1
          err = "Bebopt: option name too long: '#{name}'"
          throw new Error(err)
        return false

  _makeOpt: (name) ->
    _op = name.replace(/^.*?([:]*)$/, '$1')
    name = name.replace(/^(.*?)[:]*$/, '$1')
    if _op is '::'
      op = 'optarg'
    else if op is ':'
      op = 'arg'
    else
      op = 'flag'
    return {
      op: op,
      name: name
    }

  # a bit of black magic ;)
  `function _makeFun(context, name, cb) {
    context.prototype[name] = cb;
    return context;
  }`

  [ 'shortBeat', 'longBeat', 'halfBeat' ].forEach((funcName) =>
    listName = funcName.replace(/Beat/, '')
    return _makeFun(@, funcName, (_name, fn) ->
      # namespace err.. context injection ;)
      self = @
      { op, name } = self._makeOpt(_name)
      self._beatError(listName, name)

      if fn is undefined
        self._parent.type ?= op
        self["_#{listName}"][name] = self._parent
      else
        self["_#{listName}"][name] =
          cb: fn
          type: op
      self._parent = self["_#{listName}"][name]
      return self))

  _checkOption: (parent, child) =>
    if @["_#{parent}"][child] is undefined
      if child.length < 2
        console.error("#{@app}: invalid option -- '#{child}'")
        process.exit(1)
      else if child.length > 1
        dash = if parent is '_half' then '-' else '--'
        console.error("#{@app}: unrecognized option '#{dash}#{child}'")
        process.exit(1)
    else
      return @["_#{parent}"][child]

  _parentError: () =>
    if @_parent is null
      err = 'Bebopt: null parent ref: cannot apply'
      throw new Error(err)

  help: (text) =>
    @_parentError()
    @_parent.usage = text
    @_parent = null
    @_log(@)
    return @

  _gather: () =>
    @__rargs = process.argv
    @__pargs = @__rargs.slice(2).map((opt, ind, arr) =>
      len = opt.replace(/^(--?).*/, '$1').length
      dRef = {}
      switch len
        when 1
          opt = opt.replace(/^-/, '')
          if opt.length < 2 # short
            ref = @_short[opt]
          else
            ref = @_half[opt]
        when 2
          opt = opt.replace(/^--/, '')
          ref = @_long[opt]
      _ref = @_checkOption(dRef)
      _ref.name = dRef.child
      return _ref)

  _log: (y) ->
    console.log(util.inspect(y, { colors: true, depth: null }))

  parse: () =>
    @_gather()

module.exports = Bebopt
