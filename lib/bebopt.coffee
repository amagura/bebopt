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

util      = require 'util'
deepEqual = require('./equal')

class Bebopt
  constructor: (@app) ->
    @app ?= 'bebopt'
    @_long = {}
    @_short = {}
    @_half = {}
    @_parent = null
    @__options = []
    # XXX for the people; lol, that is this is a protected copy of `argv'
    @_raw = process.argv

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
        self["_#{listName}"][name].parent = self._parent
      else
        self["_#{listName}"][name] =
          cb: fn
          type: op
          parent: self._parent
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
  _optTypeError: (opt, dashes, list) =>
    # XXX this function MUST be called after we've already
    # taken the optargs passed in the `--OPTION ARG' fashion
    # and smooshed them in their respective @_{short,long,half} list
    # objects.
    list = null
    if dashes is 1 and opt.arg.length < 2
      list = [ @_short, 'short' ]
    else if dashes is 1 and opt.arg.length > 1
      list = [ @_half, 'half' ]
    else
      list = [ @_long, 'long' ]

    if opt.type is 'arg'
      if opt.optarg is undefined
        err = "#{@app}: "
        if list[1] is 'short'
          err += "option requires an argument -- '#{optName}'"
        else
          dashes = if list[1] is 'half' then '-' else '--'
          err += "option '#{dashes}#{optName}' requires an argument"
        console.error(err)
        process.exit(1)
      else
        list[0][opt.arg].optarg = opt.optarg
    else if opt.type is 'flag'
      if opt.optarg isnt undefined
          err = "#{@app}"
          dashes = if list[1] is 'half' then '-' else '--'
          err += "option '#{dashes}#{optName}' doesn't allow an argument"
          console.error(err)
          process.exit(1)
        else
          @[list.name][optName].arg = true

  # loops through the option lists making sure that any options that
  # if an option takes an arg
  # but that arg was specified in the
  # `--OPTION=<ARG>' fashion
  # that if the `ARG' was specified
  # in the `--OPTION <ARG>' fashion
  # that arg is added to the option's object
  # within the respective
  # option list, such as `@_long'
  _catchSpaceDelimArgs: (opt, list) =>
    if list[opt.arg].type isnt 'flag'
      if opt.optarg is undefined
        @_args.forEach((nonOpt, ind) =>
          if nonOpt.index is (opt.index + 1)
            opt.optarg = nonOpt.arg
            delete @_args[ind])
        return opt

  _resolveOpts: () =>
    @_opts.forEach((elem, ind) =>
      dashes = elem.arg.replace(/^(--?).*/, '$1').length # number of dashes
      elem.arg = elem.arg.replace(/^--?(.*)/, '$1')
      console.log elem
      if dashes is 1 and elem.arg.length < 2 # short
        elem = @_catchSpaceDelimArgs(elem, @_short)
      else if dashes is 1 and elem.arg.length > 1 # half
        elem = @_catchSpaceDelimArgs(elem, @_half)
      else if dashes is 2 and elem.arg.length > 1 # long
        elem = @_catchSpaceDelimArgs(elem, @_long)
      # check option types
      if dashes is 1 and elem.arg.length < 2 # short
        elem = @_optTypeError(elem, @_short)

    )

  _log: (y) ->
    console.log(util.inspect(y, { colors: true, depth: null }))

  parse: () =>
    @_gather()
    @_log(@)
    @_resolveOpts()
    @_log(@)

module.exports = Bebopt
