AASM = require '../lib/aasm'

class Foo
  AASM.include(this)

  @aasmInitialState 'open'

  @aasmState 'open', {exit: 'exit'}
  @aasmState 'closed', {enter: 'enter'}

  @aasmEvent 'close', {success: 'successCallback'},()->
    @transitions {to: 'closed', from: ['open']}

  @aasmEvent 'nil', {success: 'successCallback'},()->
    @transitions {to: 'closed', from: ['open'], guard: 'alwaysFalse'}

  alwaysFalse:() -> false

  successCallback:() ->
  enter:() ->
  exit:() ->

class FooTwo extends Foo
  AASM.include(this)
  @aasmState 'foo'

class Bar
  AASM.include(this)

  @aasmState 'read'
  @aasmState 'ended'

  @aasmEvent 'foo', ()->
    @transitions {to : 'ended', from: ['read']}

class Baz extends Bar

class Banker
  AASM.include(this)
  @aasmInitialState  (banker) ->
    if banker.isRich() then 'retired' else 'sellingBadMortgages'

  @aasmState 'retired'
  @aasmState 'sellingBadMortgages'

  constructor: (balance = 0) -> @balance = balance

  @RICH = 1000000

  isRich: -> @balance >= Banker.RICH

describe 'AASM - class level definitions', ->
  it 'should define a class level aasmInitialState() method on its including class', ->
    expect(Foo.aasmInitialState).toBeDefined()

  it 'should define a class level aasmState() method on its including class', ->
    expect(Foo.aasmState).toBeDefined()

  it 'should define a class level aasmEvent() method on its including class', ->
    expect(Foo.aasmEvent).toBeDefined()

  it 'should define a class level aasmStates() method on its including class', ->
    expect(Foo.aasmStates).toBeDefined()

  it 'should define a class level aasmStatesForSelect() method on its including class', ->
    expect(Foo.aasmStatesForSelect).toBeDefined()

  it 'should define a class level aasmEvents() method on its including class', ->
    expect(Foo.aasmEvents).toBeDefined()

describe 'AASM - subclassing', ->
  it 'should have the parent states', ->
    expect(FooTwo.aasmStates()).toBeDefined()
    # for state in Foo.aasmStates()
    #   expect(FooTwo.aasmStates()).toContain(state)

  xit 'should not add the child states to the parent machine', ->
    expect(Foo.aasmStatesName()).toNotContain('foo')
    #TODO fix it
    expect(FooTwo.aasmStatesName()).toContain('foo')


describe 'AASM - aasmStatesForSelect', ->
  xit "should return a select friendly array of states in the form of [['Friendly name', 'stateName']]", ->
    # console.log(Foo.aasmStatesForSelect())
    expect(Foo.aasmStatesForSelect()).toEqual([['Open', 'open'], ['Closed', 'closed']])

describe 'AASM - instance level definitions', ->
  beforeEach ->
    @foo = new Foo()

  it 'should define a state querying instance method on including class', ->
    expect(@foo.isOpen).toBeDefined()

  it 'should define an event instance method', ->
    expect(@foo.close).toBeDefined()

  it 'should define an eventAndSave instance method', ->
    expect(@foo.closeAndSave).toBeDefined()


describe 'AASM - initial states', ->
  beforeEach ->
    @foo = new Foo()
    @bar = new Bar()

  it 'should set the initial state', ->
    expect(@foo.aasmCurrentState()).toEqual('open')

  it '#isOpen should be initially true', ->
    expect(@foo.isOpen()).toEqual(true)

  it '#isClosed should be initially false', ->
    expect(@foo.isClosed()).toEqual(false)

  it 'should use the first state defined if no initial state is given', ->
    expect(@bar.aasmCurrentState()).toEqual('read')

  it 'should determine initial state from the Proc results', ->
    expect(new Banker(Banker.RICH - 1).aasmCurrentState()).toEqual('sellingBadMortgages')
    expect(new Banker(Banker.RICH + 1).aasmCurrentState()).toEqual('retired')

describe 'AASM - event firing with persistence', ->
  it 'should fire the Event', ->
    foo = new Foo()
    spyOn(Foo.aasmEvents()['close'], 'fire').andCallThrough()
    foo.closeAndSave()
    expect(Foo.aasmEvents()['close']['fire']).toHaveBeenCalledWith(foo)

  it 'should update the current state', ->
    foo = new Foo()
    foo.closeAndSave()
    expect(foo.aasmCurrentState()).toEqual('closed')

  it 'should call the success callback if one was provided', ->
    foo = new Foo()
    spyOn(foo, 'successCallback').andCallThrough()
    foo.closeAndSave()
    expect(foo.successCallback).toHaveBeenCalled()


  it 'should attempt to persist if aasmWriteState is defined', ->
    foo = new Foo()
    foo.aasmWriteState = ()->
    spyOn(foo, 'aasmWriteState').andCallThrough()
    foo.closeAndSave()
    expect(foo.aasmWriteState).toHaveBeenCalled()

  it 'should return true if aasm_write_state is defined and returns true', ->
    foo = new Foo()
    foo.aasmWriteState = (state)-> true
    expect(foo.closeAndSave()).toEqual(true)

  it 'should return false if aasmWriteState is defined and returns false', ->
    foo = new Foo()
    foo.aasmWriteState = (state)-> false
    expect(foo.closeAndSave()).toEqual(false)

  it "should not update the aasmCurrentState if the write fails", ->
    foo = new Foo()
    foo.aasmWriteState = ()-> false
    spyOn(foo, 'aasmWriteState').andCallThrough()
    foo.closeAndSave()
    expect(foo.aasmWriteState).toHaveBeenCalled()
    expect(foo.aasmCurrentState()).toEqual('open')

describe 'AASM - event firing without persistence', ->
  it 'should fire the Event', ->
    foo = new Foo()
    spyOn(Foo.aasmEvents()['close'], 'fire').andCallThrough()
    foo.close()
    expect(Foo.aasmEvents()['close']['fire']).toHaveBeenCalledWith(foo)

  it 'should update the current state', ->
    foo = new Foo()
    foo.close()
    expect(foo.aasmCurrentState()).toEqual('closed')

  it 'should attempt to persist if aasmWriteState is defined', ->
    foo = new Foo()
    foo.aasmWriteState = ()->
    foo.aasmWriteStateWithoutPersistence = ()->

    spyOn(foo, 'aasmWriteStateWithoutPersistence').andCallThrough()
    foo.close()
    expect(foo.aasmWriteStateWithoutPersistence).toHaveBeenCalled()

describe 'AASM - persistence', ->
  it 'should read the state if it has not been set and aasm_read_state is defined', ->
    foo = new Foo()
    foo.aasmReadState = ()->

    spyOn(foo, 'aasmReadState').andCallThrough()
    foo.aasmCurrentState()
    expect(foo.aasmReadState).toHaveBeenCalled()


describe 'AASM - getting events for a state', ->
  it '#aasmEventsForCurrentState should use current state', ->
    foo = new Foo()
    spyOn(foo, 'aasmCurrentState').andCallThrough()
    foo.aasmEventsForCurrentState()
    expect(foo.aasmCurrentState).toHaveBeenCalled()


  it '#aasm_events_for_current_state should use aasm_events_for_state', ->
    foo = new Foo()
    spyOn(foo, 'aasmCurrentState').andReturn('foo')
    spyOn(foo, 'aasmEventsForState').andCallThrough()
    foo.aasmEventsForCurrentState()
    expect(foo.aasmEventsForState).toHaveBeenCalledWith('foo')


describe 'AASM - event callbacks', ->
  describe "with an error callback defined", ->
    Foo.aasmEvent 'safeClose', {success: 'successCallback', error: 'errorCallback'}, ->
      @transitions to: 'closed', from: ['open']

    # beforeEach ->
    #   @foo = new Foo()

    it "should run errorCallback if an exception string is thrown and errorCallback defined", ->
      foo = new Foo()
      foo.errorCallback= (e) ->
        @errorMessage = e

      spyOn(foo, 'enter').andThrow("Do not enter")
      spyOn(foo, 'errorCallback').andCallThrough()
      foo.safeCloseAndSave()
      expect(foo.errorCallback).toHaveBeenCalled()
      expect(foo.errorMessage).toEqual("Do not enter")


    it "should run errorCallback if an exception is thrown and errorCallback defined", ->
      foo = new Foo()
      foo.errorCallback= (e) ->
        @errorMessage = e.message

      spyOn(foo, 'enter').andThrow(new Error("Do not enter"))
      spyOn(foo, 'errorCallback').andCallThrough()
      foo.safeCloseAndSave()
      expect(foo.errorCallback).toHaveBeenCalled()
      expect(foo.errorMessage).toEqual("Do not enter")


    it "should raise NoMethodError if exceptionis raised and errorCallback is declared but not defined", ->
      foo = new Foo()
      spyOn(foo, 'enter').andThrow(new Error("Do not enter"))
      try
        foo.safeCloseAndSave()
        throw new Error("Impossible")
      catch error
        expect(error).toEqual({name: "NoMethodError", message: "No such method errorCallback"})


    it "should propagate an error if no error callback is declared", ->
      foo = new Foo()
      spyOn(foo, 'enter').andThrow(new Error("Cannot enter safe"))
      try
        foo.closeAndSave()
        throw new Error("Impossible")
      catch error
        expect(error.message).toEqual("Cannot enter safe")

  describe "with aasm_event_fired defined", ->

    it 'should call it for successful AndSaved fire', ->
      foo = new Foo()
      foo.aasmEventFired = (event, from, to) ->
      spyOn(foo, 'aasmEventFired').andCallThrough()
      foo.closeAndSave()
      expect(foo.aasmEventFired).toHaveBeenCalledWith('close', 'open', 'closed')


    it 'should call it for successful non AndSaved fire', ->
      foo = new Foo()
      foo.aasmEventFired = (event, from, to) ->
      spyOn(foo, 'aasmEventFired').andCallThrough()
      foo.close()
      expect(foo.aasmEventFired).toHaveBeenCalledWith('close', 'open', 'closed')

    it 'should not call it for failing bang fire', ->
      foo = new Foo()
      foo.aasmEventFired = (event, from, to) ->
      foo.setAasmCurrentStateWithPersistence = () ->
      spyOn(foo, 'aasmEventFired').andCallThrough()
      spyOn(foo, 'setAasmCurrentStateWithPersistence').andReturn(false)
      foo.closeAndSave()
      expect(foo.aasmEventFired).not.toHaveBeenCalled()


  describe "with aasm_event_failed defined", ->
    # before do
    #   @foo = Foo.new
    #   def @foo.aasm_event_failed(event, from)
    #   end
    # end

    it 'should call it when transition failed for AndSave fire', ->
      foo = new Foo()
      foo.aasmEventFailed = (event, from) ->
      spyOn(foo, 'aasmEventFailed').andCallThrough()
      foo.nilAndSave()
      expect(foo.aasmEventFailed).toHaveBeenCalledWith('nil', 'open')

    it 'should call it when transition failed for non-AndSave fire', ->
      foo = new Foo()
      foo.aasmEventFailed = (event, from) ->
      spyOn(foo, 'aasmEventFailed').andCallThrough()
      foo.nil()
      expect(foo.aasmEventFailed).toHaveBeenCalledWith('nil', 'open')


    it 'should not call it if persist fails for bang fire', ->
      foo = new Foo()
      foo.aasmEventFailed = (event, from) ->
      foo.setAasmCurrentStateWithPersistence = () ->
      spyOn(foo, 'aasmEventFailed').andCallThrough()
      spyOn(foo, 'setAasmCurrentStateWithPersistence').andReturn(false)
      foo.closeAndSave()
      expect(foo.aasmEventFailed).toHaveBeenCalledWith('close', 'open')


describe 'AASM - state actions', ->
  it "should call enter when entering state", ->
    foo = new Foo()
    spyOn(foo, 'enter').andCallThrough()
    foo.close()
    expect(foo.enter).toHaveBeenCalled()

  it "should call exit when exiting state", ->
    foo = new Foo()
    spyOn(foo, 'exit').andCallThrough()
    foo.close()
    expect(foo.exit).toHaveBeenCalled()


describe Baz, ->
  xit "should have the same states as it's parent", ->
    expect(Baz.aasmStates()).toEqual(Bar.aasmStates())

  xit "should have the same events as it's parent", ->
    expect(Baz.aasmEvents()).toEqual(Bar.aasmEvents())

class ChetanPatil
  AASM.include(this)
  @aasmInitialState 'sleeping'
  @aasmState 'sleeping'
  @aasmState 'showering'
  @aasmState 'working'
  @aasmState 'dating'
  @aasmState 'prettyingUp'

  @aasmEvent 'wakeup', ->
    @transitions from: 'sleeping', to: ['showering', 'working']

  @aasmEvent 'dress', ->
    @transitions from: 'sleeping',  to: 'working', onTransition: 'wearClothes'
    @transitions from: 'showering', to: ['working', 'dating'], onTransition: (obj, args...) -> obj.wearClothes(args...)
    @transitions from: 'showering', to: 'prettyingUp', onTransition: ['conditionHair', 'fixHair']


  wearClothes: (shirtColor, trouserType) -> #console.log("shirtColor, trouserType", shirtColor, trouserType)

  conditionHair: () ->

  fixHair: () ->


describe ChetanPatil, ->
  it 'should transition to specified next state (sleeping to showering)', ->
    cp = new ChetanPatil()
    cp.wakeupAndSave 'showering'
    expect(cp.aasmCurrentState()).toEqual('showering')

  it 'should transition to specified next state (sleeping to working)', ->
    cp = new ChetanPatil()
    cp.wakeupAndSave 'working'
    expect(cp.aasmCurrentState()).toEqual('working')

  it 'should transition to default (first or showering) state', ->
    cp = new ChetanPatil()
    cp.wakeupAndSave()
    expect(cp.aasmCurrentState()).toEqual('showering')


  it 'should transition to default state when onTransition invoked', ->
    cp = new ChetanPatil()
    cp.dressAndSave(null, 'purple', 'dressy')
    expect(cp.aasmCurrentState()).toEqual('working')

  it 'should call onTransition method with args', ->
    cp = new ChetanPatil()
    spyOn(cp, 'wearClothes').andCallThrough()
    cp.wakeupAndSave 'showering'
    cp.dressAndSave('working', 'blue', 'jeans')
    expect(cp.wearClothes).toHaveBeenCalledWith('blue', 'jeans')

  it 'should call onTransition function', ->
    cp = new ChetanPatil()
    spyOn(cp, 'wearClothes').andCallThrough()
    cp.wakeupAndSave 'showering'
    cp.dressAndSave('dating', 'purple', 'slacks')
    expect(cp.wearClothes).toHaveBeenCalledWith('purple', 'slacks')

  it 'should call onTransition with an array of methods', ->
    cp = new ChetanPatil()
    spyOn(cp, 'conditionHair').andCallThrough()
    spyOn(cp, 'fixHair').andCallThrough()
    cp.wakeupAndSave 'showering'
    cp.dressAndSave('prettyingUp')
    expect(cp.conditionHair).toHaveBeenCalled()
    expect(cp.fixHair).toHaveBeenCalled()

