{starts, ends, compact, count, merge, extend, flatten, del, last, capitalize} = require './helpers'

module.exports = class State
  constructor: (name, options = {}) ->
    @name = name
    @update(options)

  equals: (state) ->
    @this.name is state

  callAction: (action, record) ->
    action = @options[action]
    if Array.isArray action
      try
        _callAction(anAction, record) for anAction in action
      catch HaltAasmChain
        #ignore
    else
      _callAction(action, record)

  forSelect: () -> [@displayName, @name]

  update: (options = {}) ->
    if options.display
      @displayName = del options, 'display'
    else
      @displayName = capitalize(@name.replace(/_/g, ' '))
    @options = options
    this

  _callAction= (action, record)->
    switch typeof action
      when 'string'
        record[action].call(record)
      when 'function'
        action.call(action, record)
