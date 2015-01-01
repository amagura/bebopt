'use strict'

class Bebopt
  constructor: (@app) ->
    @app ?= 'bebopt'
    @_long ?= {}
    @_short ?= {}
    @_shortLong ?= {}
    @_parent = null

  _refError: (ref) =>
    if ref[0] isnt '#'
      err = "Bebopt: ref must begin with pound: `#{ref}'"
      throw new Error(err)
    _refns = ref.replace(/^#(.*)Beat\..*/, '$1')
    _refchild = ref.replace(/^#.*Beat\.(.*)/, '$1')
    _ref = @["_#{_refns}"][_refchild]
    if _ref is undefined
      err = "Bebopt: bad reference: #{_ref}: `#{ref}'"
      throw new Error(err)

  _beatError: (parent, name, fn, desc) =>
    switch parent
      when 'long'
        if name.length < 2
          err = "Bebopt: option name too short -- `#{name}'"
          throw new Error(err)
        else if typeof(fn) is 'string'
          console.log @_refError(fn)
      when 'short'
        if name.length > 1
          err = "Bebopt: option name too long: `#{name}'"
          throw new Error(err)
        else if typeof(fn) is 'string'
          console.log @_refError(fn)

  longBeat: (name, fn, desc) =>
    @_beatError('long', name, fn, desc)
    return @

  shortBeat: (name, fn, desc) =>
    @_beatError('short', name, fn, desc)
    return @

  halfBeat: (name, fn, desc) =>
    @_beatError('long', name, fn, desc)
    return @

module.exports = Bebopt
