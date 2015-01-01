'use strict'

class Bebopt
  constructor: (@app) ->
    @app ?= 'bebopt'
    @_long ?= {}
    @_short ?= {}
    @_shortLong ?= {}

  longBeat: (name, fn, desc) =>
    if name.length < 2
      err = "Bebopt: option name too short -- `#{name}'"
      throw new Error("#{err}")
    return @

  shortBeat: (name, fn, desc) =>
    if name.length > 1
      err = "Bebopt: option name too long: `#{name}'"
      throw new Error("#{err}")
    return @

  halfBeat: (name, fn, desc) =>
    if name.length < 2
      err = "Bebopt: option name too short -- `#{name}'"
      throw new Error("#{err}")
    return @

module.exports = Bebopt
