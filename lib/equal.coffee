'use strict'
equal = require 'deep-equal'

deepEqual = (queue...) ->
  return queue.reduce((a, b) ->
    Object.keys(a).forEach((key) ->
      if a[key] instanceof Function
        a[key] = a[key].toString())
    Object.keys(b).forEach((key) ->
      if b[key] instanceof Function
        b[key] = b[key].toString())
    return equal(a, b))

module.exports = deepEqual
