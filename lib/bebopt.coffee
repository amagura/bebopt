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

  _refError: (ref) =>
    if typeof(ref) is 'string'
      if ref[0] isnt '#'
        err = "Bebopt: ref must begin with pound: '#{ref}'"
        throw new Error(err)
      _refns = ref.replace(/^#(.*)Beat\..*/, '$1')
      _refchild = ref.replace(/^#.*Beat\.(.*)/, '$1')
      _ref = @["_#{_refns}"][_refchild]
      if _ref is undefined
        err = "Bebopt: bad reference: #{_ref}: '#{ref}'"
        throw new Error(err)
      else
        _ref._isref = true
        return _ref
    else
      return false

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

  longBeat: (_name, fn) =>
    { op, name } = @_makeOpt(_name)
    @_beatError('long', name)

    if fn is undefined
      @_long[name] = @_parent
    else
      @_long[name] =
        cb: fn
    @_parent = @_long[name]
    return @

  _makeOpt: (name) ->
    return {
      op: name.replace(/^.*([:]*)$/, '$1'),
      name: name.replace(/^(.*)[:]*$/, '$1')
    }

  shortBeat: (_name, fn) =>
    { op, name } = @_makeOpt(_name)
    @_beatError('short', name)

    if fn is undefined
      @_short[name] = @_parent
    else
      @_short[name] =
        cb: fn
    @_parent = @_short[name]
    return @

  halfBeat: (_name, fn) =>
    { op, name } = @_makeOpt(_name)
    @_beatError('long', name)

    if fn is undefined
      @_short[name] = @_parent
    else
      @_short[name] =
        cb: fn
    @_parent = @_short[name]
    return @

  _decodeRef: (ref) ->
    if typeof(ref) is 'string'
      if ref[0] isnt '#'
        err = "Bebopt: ref must begin with pound: '#{ref}'"
        throw new Error(err)
      _refns = ref.replace(/^#(.*)Beat\..*/, '$1')
      _refchild = ref.replace(/^#.*Beat\.(.*)/, '$1')
      _ref =
        parent: "_#{_refns}"
        child: _refchild
      return _ref

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

  op: (code, help) =>
    if @_parent is null
      err = "Bebopt: null parent ref: cannot apply opcode: '#{code}'"
      throw new Error(err)
    ref = @_decodeRef(@_parent)
    switch code
      when '::'
        @[ref.parent][ref.child].type = 'optarg'
      when ':'
        @[ref.parent][ref.child].type = 'arg'
    if help isnt undefined and help isnt null
      @[ref.parent][ref.child].help = true
    @_parent = null
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

  parse: () =>
    @_gather()
    console.log(util.inspect(@, { colors: true, depth: null }))

module.exports = Bebopt
