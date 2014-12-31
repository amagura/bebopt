'use strict'

class Bebopt
  constructor: (@app) ->
    @app ?= 'bebopt'
    @_long ?= {}
    @_short ?= {}
    @_shortLong ?= {}

  alias: (_alias, name) =>
    if typeof(_alias) is 'array' and typeof(name) is 'array'
      name.forEach (opt, ind) =>
        _opt = opt.replace(/^--\s*/, '')
        [
          [/^--/, '^--'],
          [/^-[^-]/, '^-[^-]']
        ].forEach (rgx) =>
          switch rgx[0].test(opt)
            when true
              if _alias[ind].length is 1
                @_short[_opt] ?= @_long[_opt] if rgx[1] is '^--' else @_shortLong
            else
              if @_shortLong.indexOf(_opt) is -1
                @_shortLong[_opt] = @_long[_opt]
              else
                @_long[_opt] ?= @_long[_opt]
        switch


        if /^--/.test(opt)
          @_long[opt.replace(/^--\s*/, '')]


  detail: (name, desc, fn) =>
    if typeof(name) is 'array'
      @_long[name[0]] =
        fn: fn,
        desc: desc,
        type: switch name.length
          when 1
            'flag'
          else
            switch name[1]
              when '::'
                'optarg'
              when ':'
                'arg'
              else
                'flag'
    else
      @_long[name[0]] =
        fn: fn,
        desc: desc,
        type: 'flag'

  describe: (name, desc, fn) =>
    if typeof(name) is 'array'
      @_shortLong[name[0]] =
        fn: fn,
        desc: desc,
        type: switch name.length
          when 1
            'flag'
          else
            switch name[1]
              when '::'
                'optarg'
              when ':'
                'arg'
              else
                'flag'
    else
      @_shortLong[name[0]] =
        fn: fn,
        desc: desc,
        type: 'flag'

module.exports = Bebopt
