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
    @__options = []
    @_raw = process.argv # XXX for the people; lol, that is this is a protected copy

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

  _optError: (parent, child) =>
    if @["_#{parent}"][child] is undefined
      if child.length < 2
        console.error("#{@app}: invalid option -- '#{child}'")
        process.exit(1)
      else if child.length > 1
        dash = if parent is 'half' then '-' else '--'
        console.error("#{@app}: unrecognized option '#{dash}#{child}'")
        process.exit(1)

  _parentError: () =>
    if @_parent is null
      err = 'Bebopt: null parent ref: cannot apply'
      throw new Error(err)

  help: (text) =>
    @_parentError()
    @_parent.usage = text
    @_parent = null
    return @

  _sepOptArg: (opt) ->
    if ///=///.test(opt)
      arg = opt.replace(/.*?=(.*)/, '$1')
    else
      arg = undefined
    _opt = opt.replace(/(.*)?=.*/, '$1')
    return {
      opt: _opt,
      _arg: arg
    }

# processes `process.arv' producing two arrays, one containing options,
# their indexes and any arguments passed in the `--OPTION=ARG' fashion,
# and then another containing non-option arguments
  _gather: () =>
    @_opts = []
    @_args = []
    optend = false
    process.argv.slice(2).forEach((arg, ind, arr) =>
      if /^--$/.test(arg)
        optend = true
      else
        # if optend or no dashes are found in the arg,
        # then we have an non-option argument
        if optend or /^[^-]+/.test(arg) is true
          @_args.push({
            arg: arg,
            index: ind})
        else # else, we are working with an option
          { opt, _arg } = @_sepOptArg(arg)
          @_opts.push({
            arg: opt,
            optarg: _arg,
            index: ind }))

# validates the incoming command-line options
# e.g. if an option that takes a required arg
# has no arg, then it causes bebopt to exit
# non-zero and prints an error message.
  _optTypeError: (optName, optArg, nofDashes) =>
    [
      {
        dashes: 1,
        name: '_short',
        minOptLen: 1
      },
      {
        dashes: 2,
        name: '_long',
        minOptLen: 2
      },
      {
        dashes: 1,
        name: '_half',
        minOptLen: 2
      },
      # `list' refers to the fact that `_long', `_short', and `_half' are
      # the objects where the defined options are stored
    ].forEach((list) =>
      if nofDashes is list.dashes
        type = @[list.name][optName].type
        switch type
          when 'optarg'
            if optArg isnt undefined
              @[list.name][optName].arg = optArg


      when 1
        switch @_short

  _resolveOpts: () =>
    @_opts.forEach((elem, ind) =>
      len = elem.arg.replace(/^(--?).*/, '$1').length
      elem.arg = elem.arg.replace(/^--?(.*)/, '$1')
      console.log elem.arg
      switch len
        when 1
          @_short(elem.arg)
    )
        #parent = null
        #switch len
          #when 1
            #opt = opt.replace(/^-/, '')
            #if opt.length < 2 # short
              #ref = @_short[opt]
              #parent = 'short'
            #else
              #ref = @_half[opt]
              #parent = 'half'
          #when 2
            #opt = opt.replace(/^--/, '')
            #ref = @_long[opt]
            #parent = 'long'
        #console.log opt
        #@_optError(parent, opt)
      #else
        #return ref)

  _log: (y) ->
    console.log(util.inspect(y, { colors: true, depth: null }))

  parse: () =>
    @_gather()
    @_log(@)
    @_resolveOpts()

module.exports = Bebopt
