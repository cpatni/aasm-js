StateMachine = require './state_machine'
Event = require './event'

module.exports = class AASM

  ClassMethods =
    aasmInitialState: (initialState) ->
      #this refers to the class object here which is mixing in this module
      if initialState
        StateMachine[this].initialState = initialState
      else
        StateMachine[this].initialState

    aasmState: (name, options={}) ->
      sm = StateMachine[this]
      sm.createState(name, options)
      sm.initialState = name unless sm.initialState
      isMethod = "is#{name.substr(0,1).toUpperCase()}#{name.substr(1)}"
      this.prototype[isMethod] = () ->  @aasmCurrentState() is name

    aasmEvent: (name, options = {}, block) ->
      if typeof options is 'function'
        block = options
        options = {}
      sm = StateMachine[this]
      unless sm.events[name]
        sm.events[name] = new Event(name, options, block)

      this.prototype[name]= (args...) ->
        @aasmFireEvent(name, false, args...)

      this.prototype["#{name}AndSave"]= (args...) ->
        @aasmFireEvent(name, true, args...)


    aasmStates:() -> StateMachine[this].states

    aasmStatesName:() -> StateMachine[this].statesName()

    aasmEvents:() -> StateMachine[this].events

    aasmStatesForSelect:() ->
      console.log(@aasmStates())
      StateMachine[this].states.map (state) ->
        console.log("..AAAAA....", state)
        state.forSelect()


  #Prototype methods
  PrototypeMethods =
    aasmCurrentState: () ->
      # console.log("...._aasm_current_state", @_aasm_current_state)
      return @_aasmCurrentState if @_aasmCurrentState
      if @aasmReadState?
        @_aasmCurrentState = @aasmReadState()
      return @_aasmCurrentState if @_aasmCurrentState
      @aasmEnterInitialState()

    aasmEnterInitialState: () ->
      stateName = @aasmDetermineStateName(@constructor.aasmInitialState())
      state = @aasmStateObjectForState(stateName)

      # console.log("state_name-------------befirecall_action>",state.constructor.name)
      state.callAction('beforeEnter', this)
      #console.log("state_name-------------call_action>",state.constructor.name)
      state.callAction('enter', this)
      @_aasmCurrentState = stateName
      state.callAction('afterEnter', this)
      stateName

    aasmEventsForCurrentState: () ->
      @aasmEventsForState(@aasmCurrentState())

    aasmEventsForState: (state) ->
      values = (value for name, value of this.constructor.aasmEvents())
      events = values.filter (event)-> event.isTransitionsFromState(state)
      events.map (event) -> event.name

  #   private

    setAasmCurrentStateWithPersistence: (state) ->
      saveSuccess = true
      if @aasmWriteState?
        saveSuccess = @aasmWriteState(state)
      @_aasmCurrentState = state if saveSuccess
      saveSuccess

    setAasmCurrentState: (state)->
      if @aasmWriteStateWithoutPersistence?
        @aasmWriteStateWithoutPersistence(state)
      @_aasmCurrentState = state

    aasmDetermineStateName: (state)->
      switch typeof state
        when 'string'
          state
        when 'function'
          state.call(this, this)
        else
          throw {name: "NotImplementedError", message: "Unrecognized state-type given.  Expected String, or Function."}

    aasmStateObjectForState: (name)->
      #TODO filter == find?
      obj = @constructor.aasmStates().filter (s) -> s.name is name
      throw {name: "UndefinedState", message: "State :#{name} doesn't exist"} unless obj
      obj[0]


    aasmFireEvent: (name, persist, args...) ->
      event = @constructor.aasmEvents()[name]
      try
        oldState = @aasmStateObjectForState(@aasmCurrentState())
        oldState.callAction('exit', this)

        # new event before callback
        event.callAction('before', this)
        newStateName = event.fire(this, args...)

        unless newStateName is null
          newState = @aasmStateObjectForState(newStateName)

          # new before_ callbacks
          oldState.callAction('beforeExit', this)
          newState.callAction('beforeEnter', this)

          newState.callAction('enter', this)

          persistSuccessful = true
          if persist
            persistSuccessful = @setAasmCurrentStateWithPersistence(newStateName)
            event.executeSuccessCallback(this) if persistSuccessful
          else
            @setAasmCurrentState newStateName

          if persistSuccessful
            oldState.callAction('afterExit', this)
            newState.callAction('afterEnter', this)
            event.callAction('after', this)
            @aasmEventFired(name, oldState.name, @aasmCurrentState()) if @aasmEventFired
          else
            @aasmEventFailed(name, oldState.name) if @aasmEventFailed

          persistSuccessful
        else
          if @aasmEventFailed
            @aasmEventFailed(name, oldState.name)
          false
      catch e
        event.executeErrorCallback(this, e)

  @include = (klass) ->
    klass[name] = method for name, method of ClassMethods
    klass.prototype[name] = method for name, method of PrototypeMethods
    StateMachine.register(klass)


