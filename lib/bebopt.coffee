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
clone     = require 'clone'
deepEqual = require './deep-equal'
basename  = require('path').basename

class Bebopt
  constructor: (@app) ->
    @app ?= basename(process.argv[1])
    @_options = []
    @_parent = null
    # XXX for the people; lol, that is this is a protected copy of `argv'
    @_raw = process.argv
    @_cooked = []
    @_eaten = {}
    @usage = undefined
    @_help = []

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
    new_op = name.replace(/^.*?([:]*)$/, '$1')
    name = name.replace(/^(.*?)[:]*$/, '$1')
    if new_op is '::'
      op = 'optarg'
    else if new_op is ':'
      op = 'arg'
    else
      op = 'flag'
    return {
      op: op,
      name: name
    }

  # creates a function as a prototype of `context'.
  # can be used to mass-produce class methods
  `function _makeFun(context, name, cb) {
    context.prototype[name] = cb;
    return context;
  }`

  [ 'shortBeat', 'longBeat' ].forEach((funcName) =>
    listName = funcName.replace(/Beat/, '')
    return _makeFun(@, funcName, (_name, fn) ->
      self = @
      # determine the type of OPTION, based on the OPTION's name
      { op, name } = self._makeOpt(_name)
      self._beatError(listName, name)

      if fn is undefined
        self._parent.type ?= op
        child = clone(self._parent)
        # give child a pointer to its parent
        child.parent = self._parent
        child.parent.index = child.index

        ++child.index # increment child.index again to set it to its own index
        child.name = name
        child.list = listName
        # give parent a pointer to its child
        self._parent.child = child
        self._options.push(child)
      else
        option =
          cb: fn
          type: op
          name: name
          list: listName
          child: null
          parent: null
        self._options.push(option)
        index = self._options.length - 1
        option = self._options.pop()
        option.index = index
        self._options.push(option)
      self._parent = self._options.slice(-1)[0]
      return self))

  help: (text) =>
    if @_parent is null
      err = 'Bebopt: null parent ref: cannot apply'
      throw new Error(err)
    @_parent.usage = text
    @_parent = null
    return @

  _parentOrChildUsage: (opt) =>
    if typeof opt.usage isnt 'string'
      if opt.parent is null
        if opt.child is null
          return ''
        else
          return @_options[opt.child.index].usage
      else
        return @_options[opt.parent.index].usage
    else
      return opt.usage

  _makeHelp: () =>
    @_options.forEach((opt) =>
      dashes = if opt.list is 'short' then '-' else '--'
      usage = @_parentOrChildUsage(opt)
      if opt.child is null
        if opt.parent is null
          @_help.push("  #{dashes}#{opt.name}#{usage}")
      else
        if opt.parent is null
          if dashes is '--'
            @_help.push("  -#{opt.child.name}, #{dashes}#{opt.name}#{usage}")
          else
            @_help.push("  #{dashes}#{opt.name}, --#{opt.child.name}#{usage}")
    )
    @_log(@)

  printHelp: (fn) =>
    usage = if @usage is undefined then "Usage: #{@app}" else @usage
    if fn is undefined
      console.error(usage)
      @_help.forEach((txt) ->
        console.error(txt))
    else
      fn(usage)
      @_help.forEach((txt) ->
        fn(txt))

  usage: (text) =>
    @usage = text

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
        @_bindOptToList(elem, 'long')
        food = clone(@_long[elem.arg])
        @_cooked.push(food)
      else
        if @_takesArg(elem, 'short')
          elem = @_catchSpaceDelimArgs(elem, @_short)
        @_bindOptToList(elem, 'short')
        food = clone(@_short[elem.arg])
        @_cooked.push(food))

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

  _runCallbacks: () =>
    @_cooked.forEach((food) =>
      optarg = food.cb.apply(@, [food.optarg])
      food.names.forEach((name) =>
        yummy = optarg
        @_eaten[name] = yummy))

  _clean: () =>
    Object.keys(@).forEach((key) =>
      if /^_/.test(key)
        [
          '_runCallbacks',
          '_log',
          '_raw',
          '_cooked',
          '_eaten',
          '_help'
        ].forEach((target) =>
          if key isnt target
            delete @[key]))
    return @

  parse: () =>
    @_makeHelp()
    @_gather()
    @_resolveOpts()
    #@_runCallbacks()

module.exports = Bebopt
