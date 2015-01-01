'use strict'

if 0 # FIXME remove me
  log = require './log'
else
  log = require './log'
  log = log.fake()

class Bebopt
  constructor: (@app) ->
    @app ?= 'bebopt'
    @_long ?= {}
    @_short ?= {}
    @_half ?= {}
    @_parent = null
    @__rargs = [] # raw args
    @__pargs = {} # processed args

  _refError: (ref) =>
    if typeof(ref) is 'string'
      if ref[0] isnt '#'
        err = "Bebopt: ref must begin with pound: `#{ref}'"
        throw new Error(err)
      _refns = ref.replace(/^#(.*)Beat\..*/, '$1')
      _refchild = ref.replace(/^#.*Beat\.(.*)/, '$1')
      _ref = @["_#{_refns}"][_refchild]
      if _ref is undefined
        err = "Bebopt: bad reference: #{_ref}: `#{ref}'"
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
          err = "Bebopt: option name too short -- `#{name}'"
          throw new Error(err)
        return false
      when 'short'
        if name.length > 1
          err = "Bebopt: option name too long: `#{name}'"
          throw new Error(err)
        return false

  longBeat: (name, fn, desc) =>
    @_beatError('long', name)
    _ref = @_refError(fn)
    
    if _ref is false
      @_long[name] =
        name: name,
        fn: fn,
        desc: desc,
        type: 'flag'
    else
      @_long[name] = _ref
    @_parent = "#longBeat.#{name}"
    return @

  shortBeat: (name, fn, desc) =>
    @_beatError('short', name)
    _ref = @_refError(fn)
    
    if _ref is false
      @_short[name] =
        name: name,
        fn: fn,
        desc: desc,
        type: 'flag'
      @_parent = "#shortBeat.#{name}"
    else
      @_short[name] = _ref
    return @

  halfBeat: (name, fn, desc) =>
    @_beatError('long', name)
    _ref = @_refError(fn)
    
    if _ref is false
      @_half[name] =
        name: name,
        fn: fn,
        desc: desc,
        type: 'flag'
      @_parent = "#shortBeat.#{name}"
    else
      @_half[name] = _ref
    return @

  _decodeRef: (ref) ->
    if typeof(ref) is 'string'
      if ref[0] isnt '#'
        err = "Bebopt: ref must begin with pound: `#{ref}'"
        throw new Error(err)
      _refns = ref.replace(/^#(.*)Beat\..*/, '$1')
      _refchild = ref.replace(/^#.*Beat\.(.*)/, '$1')
      _ref =
        parent: "_#{_refns}"
        child: _refchild
      if _ref is undefined
        err = "Bebopt: bad reference: #{_ref}: `#{ref}'"
        throw new Error(err)
      else
        return _ref

  op: (code, help) =>
    if @_parent is null
      err = "Bebopt: null parent ref: cannot apply opcode: `#{code}'"
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

  parse: () =>
    @__rargs = process.argv
    @__rargs.slice(2).forEach((opt, ind, arr) =>
      len = opt.replace(/^(--?).*/, '$1').length
      switch len
        when 1
          opt = opt.replace(/^-/, '')
          if opt.length < 2
            ref = @_refError("#shortBeat.#{opt}")
            @__pargs +=



            console.log(ref)
        when 2
          opt = opt.replace(/^--/, '')
    )

    console.log(@)

module.exports = Bebopt
