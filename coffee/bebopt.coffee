'use strict'

class Bebopt
  constructor: (@app) ->
    @app ?= 'bebopt'
    @_long ?= {}
    @_short ?= {}
    @_shortLong ?= {}

  longBeat: (name, fn, desc) =>
    if (name.length < 2) and (typeof(fn) isnt 'string')
      err = "bebopt: long option name too short; not in reference -- `#{name}'"
      throw new Error("#{err}")

  shortBeat: (name, fn, desc) =>
  halfBeat: (name, fn, desc) =>

module.exports = Bebopt
