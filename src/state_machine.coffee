{merge} = require './helpers'
State = require './state'
module.exports = class StateMachine extends Object
  @machines = {}

  @register: (klass) ->
    sm = new StateMachine('')
    @machines[klass] = sm
    @[klass] = sm

  constructor: (name) ->
    @name = name
    @initialState = null
    @states = []
    @events = {}
    @config = {}

  clone: () ->
    klone = merge(this, {})
    klone.states = merge @states, {}
    klone.events = merge @events, {}
    klone

  statesName: ()-> @states.map (state)-> state.name

  createState: (name, options) ->
    #TODO check for dup state name
    @states.push(new State(name, options))