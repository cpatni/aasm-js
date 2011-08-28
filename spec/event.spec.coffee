{starts, ends, compact, count, merge, extend, flatten, del, last} = require '../lib/helpers'

Event = require '../lib/event'
AASM = require '../lib/aasm'

describe 'Event', ->

  beforeEach ->
    @name    = 'close_order'
    @success = 'successCallback'
    @event   = new Event @name, {success: @success}, ->
      @transitions= {to: 'closed', from: ['open', 'received']}

  it 'should set the name', ->
    expect(@event.name).toEqual(@name)

  it 'should set the success option', ->
    expect(@event.success).toEqual(@success)

  it 'should create StateTransitions', ->
    # StateTransition.should_receive(:new).with({:to => :closed, :from => :open})
    # StateTransition.should_receive(:new).with({:to => :closed, :from => :received})
    event = new Event @name, {success: @success}, ->
      @transitions({to: 'closed', from: ['open', 'received']})
    expect(event._transitions.length).toEqual(2)
    expect(event._transitions[0].constructor.name).toEqual('StateTransition')
    expect(event._transitions[1].constructor.name).toEqual('StateTransition')

  describe 'when firing an event', ->
    it 'should raise an InvalidTransition error if the transitions are empty', ->
      obj = {aasmCurrentState: 'open'}
      event = new Event 'event', {}
      obj = {aasmCurrentState: 'open'}
      expect(() -> event.fire(obj)).toThrow({name: 'InvalidTransition', message: "Event 'event' cannot transition from 'open'"})

    it 'should return the state of the first matching transition it finds', ->
      event = new Event 'event', {},  ->
        @transitions({to: 'closed', from: ['open', 'received']})
      obj = {aasmCurrentState: 'open'}
      expect(event.fire(obj)).toEqual('closed')


    it 'should call the guard with the params passed in', ->
      event = new Event 'event', {},  ->
        @transitions({to: 'closed', from: ['open', 'received'], guard: 'guard_fn'})
      obj =
        aasmCurrentState: 'open'
        guard_fn: (arg1, arg2)->
          expect(arg1).toEqual('arg1')
          expect(arg2).toEqual('arg2')
          true
      spyOn(obj, 'guard_fn').andCallThrough()
      #andReturn(true)
      #obj.should_receive(:guard_fn).with('arg1', 'arg2').and_return(true)
      expect(event.fire(obj, null, 'arg1', 'arg2')).toEqual('closed')
      expect(obj.guard_fn).toHaveBeenCalled()

  describe 'when executing the success callback', ->

   class ThisNameBetterNotBeInUse
     AASM.include(this)
     @aasmState 'initial'
     @aasmState 'string'
     @aasmState 'array'
     @aasmState 'function'

     constructor: () ->

     stringSuccessCallback: ()-> true

     functionSuccessCallback: () -> true

     successCallback1: ()-> true
     successCallback2: ()-> true

   it "should send the success callback if it's a string", ->
     ThisNameBetterNotBeInUse.aasmEvent 'withString', {'success': 'stringSuccessCallback'}, ()->
       @transitions {'to': 'string', 'from': ['initial']}
     model = new ThisNameBetterNotBeInUse()
     spyOn(model, 'stringSuccessCallback').andCallThrough()
     model.withStringAndSave()
     expect(model.stringSuccessCallback).toHaveBeenCalled()

   it "should call each success callback if passed an array of strings", ->
     ThisNameBetterNotBeInUse.aasmEvent 'withArray', {'success': ['successCallback1', 'successCallback2']}, ()->
       @transitions {'to': 'array', 'from': ['initial']}
     model = new ThisNameBetterNotBeInUse()
     spyOn(model, 'successCallback1').andCallThrough()
     spyOn(model, 'successCallback2').andCallThrough()
     model.withArrayAndSave()
     expect(model.successCallback1).toHaveBeenCalled()
     expect(model.successCallback2).toHaveBeenCalled()

   it "should call each success callback if passed an array of strings and/or functions", ->
     ThisNameBetterNotBeInUse.aasmEvent 'withArrayIncludingFunctions', {'success': ['successCallback1', 'successCallback2', (obj) -> obj.functionSuccessCallback() ]}, ()->
       @transitions {'to': 'array', 'from': ['initial']}
     model = new ThisNameBetterNotBeInUse()
     spyOn(model, 'successCallback1').andCallThrough()
     spyOn(model, 'successCallback2').andCallThrough()
     spyOn(model, 'functionSuccessCallback').andCallThrough()
     model.withArrayIncludingFunctionsAndSave()
     expect(model.successCallback1).toHaveBeenCalled()
     expect(model.successCallback2).toHaveBeenCalled()
     expect(model.functionSuccessCallback).toHaveBeenCalled()

   it "should call the success callback if it's a function", ->
     ThisNameBetterNotBeInUse.aasmEvent 'withFunction', {'success': (obj) -> obj.functionSuccessCallback()}, ()->
       @transitions {'to': 'function', 'from': ['initial']}
     model = new ThisNameBetterNotBeInUse()
     spyOn(model, 'functionSuccessCallback').andCallThrough()
     model.withArrayIncludingFunctionsAndSave()
     expect(model.functionSuccessCallback).toHaveBeenCalled()

