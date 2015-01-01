'use strict'

if 1
  log = require './log'
else
  log = require './log'
  log = log.fake()

class Bebopt
  constructor: (@app) ->
    @app ?= 'bebopt'
    @_long ?= {}
    @_short ?= {}
    @_shortLong ?= {}
    @_parent = null

  _refError: (ref) =>
    if typeof(ref) is 'string'
      if ref[0] isnt '#'
        err = "Bebopt: ref must begin with pound: `#{ref}'"
        throw new Error(err)
      _refns = ref.replace(/^#(.*)Beat\..*/, '$1')
      _refchild = ref.replace(/^#.*Beat\.(.*)/, '$1')
      _ref = @["_#{_refns}"][_refchild]
      log.GOOFY(_ref)
      log.GOOFY(_refns)
      log.GOOFY(_refchild)
      if _ref is undefined
        err = "Bebopt: bad reference: #{_ref}: `#{ref}'"
        throw new Error(err)
      else
        return _ref
    else
      return false

  _beatError: (parent, name, fn, desc) ->
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
    @_beatError('long', name, fn, desc)
    _ref = @_refError(fn)
    
    if _ref is false
      @_long[name] =
        fn: fn,
        desc: desc,
        type: 'flag'
    else
      @_long[name] = _ref
    return @

  shortBeat: (name, fn, desc) =>
    @_beatError('short', name, fn, desc)
    _ref = @_refError(fn)
    
    if _ref is false
      @_short[name] =
        fn: fn,
        desc: desc,
        type: 'flag'
    else
      @_short[name] = _ref
    return @

  halfBeat: (name, fn, desc) =>
    @_beatError('long', name, fn, desc)
    _ref = @_refError(fn)
    
    if _ref is false
      @_shortLong[name] =
        fn: fn,
        desc: desc,
        type: 'flag'
    else
      @_shortLong[name] = _ref
    return @

module.exports = Bebopt
