module.exports = class StateTransition

  constructor: (opts) ->
    {from: @from, to: @to, guard: @guard, onTransition: @onTransition} = opts
    @opts = opts

  perform: (obj, args...) ->
    switch typeof @guard
      when 'string'
        obj[@guard].call(obj, args...)
      when 'function'
        @guard.call(null, obj, args...)
      else
        true

  execute: (obj, args...) ->
    if Array.isArray @onTransition
      @_execute(obj, ot, args...) for ot in @onTransition
    else
      @_execute(obj, @onTransition, args...)

  equals: (obj) ->
    @from is obj.from and @to is obj.to

  isFrom: (value) -> @from is value

  isTo: (value) -> @to is value

  _execute: (obj, onTransition, args...) ->
    switch typeof onTransition
      when 'string'
        obj[onTransition].call(obj, obj, args...)
      when 'function'
        try
          onTransition.call(obj, obj, args...)
        catch error
          console.trace()


