StateTransition = require './state_transition'
{merge, flatten} = require './helpers'

module.exports = class Event

  constructor: (name, options = {}, callback) ->
    @name = name
    @_transitions = []
    @update(options, callback)

  fire: (obj, toState = null, args...) ->
    aasmCurrentState = if typeof obj.aasmCurrentState is 'function'
      obj.aasmCurrentState()
    else
      obj.aasmCurrentState

    transitions = @_transitions.filter (t)-> t.from is aasmCurrentState
    if transitions.length is 0
      throw {name: "InvalidTransition", message: "Event '#{@name}' cannot transition from '#{aasmCurrentState}'"}

    nextState = null
    for transition in transitions
      continue if toState and flatten([transition.to]).indexOf(toState) < 0
      if transition.perform(obj, args...)
        nextState = toState ? flatten([transition.to])[0]
        transition.execute(obj, args...)
        break
    nextState

  isTransitionsFromState: (state) ->
    @_transitions.some (t) -> t.from is state

  transitionsFromState: (state) ->
    @_transitions.filter (t) -> t.from is state

  callAction: (action, record) ->
    action = @options[action]
    if Array.isArray action
      @_callAction(anAction, record) for anAction in action
    else
      @_callAction(action, record)

  equals: (event) ->
    @name is event.name

  update: (options = {}, block)->
    if options.success
      @success = options.success
    if options.error
      @error = options.error
    if block
      block.call(this)
    @options = options
    this

  executeSuccessCallback: (obj, success = null)->

    callback = success ? @success
    switch typeof callback
      when 'string'
        obj[callback].call(obj)
      when 'function'
        try
          callback.call(obj, obj)
        catch error
          console.log(error)
      else
        if Array.isArray(callback)
          @executeSuccessCallback(obj, meth) for meth in callback
        else
          "Unknow type #{callback}"


  executeErrorCallback: (obj, error, errorCallback=null)->
    callback = errorCallback || @error
    throw  error unless callback
    switch typeof callback
      when 'string'
        unless obj[callback]
          throw {name: "NoMethodError", message: "No such method #{callback}"}
        obj[callback].call(obj, error)
      when 'function'
        callback.call(obj, error)
      else
        if Array.isArray(callback)
          @executeErrorCallback(obj, error, meth) for meth in callback
        else
          "Unknow type #{callback}"


  _callAction: (action, record)->
    switch typeof action
      when 'string'
        record[action].call(record)
      when 'function'
        action.call(record)

  transitions: (transOpts) ->
    if transOpts?
      if Array.isArray(transOpts.from)
        for from in transOpts.from
          @_transitions.push(new StateTransition(merge(transOpts, {from: from})))
      else
        @_transitions.push(new StateTransition(transOpts))
    else
      @_transitions

