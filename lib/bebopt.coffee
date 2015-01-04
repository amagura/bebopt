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
deepEqual = require './equal'
clone     = require 'clone'

class Bebopt
  constructor: (@app) ->
    @app ?= 'bebopt'
    @_long = {}
    @_short = {}
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

  [ 'shortBeat', 'longBeat' ].forEach((funcName) =>
    listName = funcName.replace(/Beat/, '')
    return _makeFun(@, funcName, (_name, fn) ->
      # namespace err.. context injection ;)
      self = @
      { op, name } = self._makeOpt(_name)
      self._beatError(listName, name)

      if fn is undefined
        self._parent.type ?= op
        self["_#{listName}"][name] = self._parent
        #self["_#{listName}"][name].parent = self._parent
      else
        self["_#{listName}"][name] =
          cb: fn
          type: op
          #parent: self._parent
      self._parent = self["_#{listName}"][name]
      return self))

  help: (text) =>
    if @_parent is null
      err = 'Bebopt: null parent ref: cannot apply'
      throw new Error(err)
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

  _catchInvalidOpt: (opt, list) =>
    if list is 'short' and @_short[opt.arg] is undefined
      console.error("#{@app}: invalid option -- '#{opt.arg}'")
      process.exit(1)
    else if list is 'long' and @_long[opt.arg] is undefined
      console.error("#{@app}: unrecognized option '--#{opt.arg}'")
      process.exit(1)

  _syncIndexes: (list, gte) ->
    list.forEach((elem) ->
      if elem.index >= gte
        ++elem.index)
    return list

# XXX transforms `-hxv' into `-h -x -v'
  _splitCombinedShorts: () =>
    @_opts.forEach((elem, ind) =>
      dashes = elem.arg.replace(/^(--?).*/, '$1').length # number of dashes
      if dashes is 1
        opts = elem.arg.replace(/^-(.*)/, '$1').split('')
        opts = opts.reverse()
        elem.arg = opts.pop()
        while opts.length > 0
          _elem = clone(elem)
          _elem.arg = opts.pop()
          if @_args[_elem.index] isnt undefined
            @_syncIndexes(@_args, _elem.index)
          @_syncIndexes(@_opts, _elem.index + 1)
          ++_elem.index
          console.log _elem
          @_opts.push(_elem))

  _takesArg: (opt, listName) =>
    @_catchInvalidOpt(opt, listName)
    if listName is 'short'
      type = @_short[opt.arg].type
      if type isnt 'flag'
        return true
      else
        return false
    else
      type = @_long[opt.arg].type
      if type isnt 'flag'
        return true
      else
        return false

  _log: (y) ->
    console.log(util.inspect(y, { colors: true, depth: null }))

  _resolveOpts: () =>
    @_splitCombinedShorts()
    @_opts.forEach((elem, ind) =>
      dashes = elem.arg.replace(/^(--?).*/, '$1').length # number of dashes
      elem.arg = elem.arg.replace(/^--?(.*)/, '$1')
      if dashes is 2
        if @_takesArg(elem, 'long')
          elem = @_catchSpaceDelimArgs(elem, @_long)
        console.log elem
        @_bindOptToList(elem, 'long')
      else
        if @_takesArg(elem, 'short')
          elem = @_catchSpaceDelimArgs(elem, @_short)
        console.log elem
        @_bindOptToList(elem, 'short')

    )

  _bindOptToList: (opt, listName) =>
    list = @["_#{listName}"]
    type = list[opt.arg].type
    if type is 'arg'
      if opt.optarg is undefined
        err = "#{@app}: "
        if listName is 'short'
          err += "option requires an argument -- '#{opt.arg}'"
        else
          err += "option '--#{opt.arg}' requires an argument"
        console.error(err)
        process.exit(1)
      else
        list[opt.arg].optarg = opt.optarg
    else if type is 'optarg'
      list[opt.arg].optarg = opt.optarg
    else if type is 'flag'
      if opt.optarg isnt undefined
        err = "#{@app}"
        err += "option '--#{opt.arg}' doesn't allow an argument"
        console.error(err)
        process.exit(1)
      else
        list[opt.arg].optarg = true

# processes `process.arv' producing two arrays, one containing options,
# their indexes and any arguments passed in the `--OPTION=ARG' fashion,
# and then another containing non-option arguments
  _gather: () =>
    @_opts = []
    @_args = []
    optend = false
    noopt = false
    process.argv.slice(2).forEach((arg, ind, arr) =>
      if /^--$/.test(arg)
        optend = true
      else if /^-$/.test(arg)
        noopt = true # XXX prevents `-' from creating an empty option object
        # when found on the command-line: e.g. `cat -'
        # NOTE that `-' traditionally means READ FROM STDIN
        # however, in the case of an option parser...
        # well, I think that it's meaningless.
        # we should never read from STDIN, as
        # an option parser has no business doing so.
        # although being able to echo options like so would be interesting:
        # `echo -- '-vhx' | <PROGRAM USING BEBOPT>` lulz
      else
        if noopt
          null # do nothing
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

  parse: () =>
    @_gather()
    @_resolveOpts()
    @_log(@)

module.exports = Bebopt
