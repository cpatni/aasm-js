State = require '../lib/state'
describe 'State', ->

  beforeEach ->
    @name    = 'astate'
    @options = { crazyCustomKey: 'key' }
    @state = new State(@name, @options)

  it 'should set the name', ->
    expect(@state.name).toEqual(@name)

  it 'should set the options and expose them as options', ->
    expect(@state.options).toEqual(@options)

  it 'should be equal to a State of the same name', ->
    expect(@state.name).toEqual(new State("astate").name)

  it 'should send a message to the record for an action if the action is present as a string', ->
    state = new State("astate", { entering: 'foo' })
    record = foo: ->
    spyOn(record, 'foo')
    state.callAction('entering', record)
    expect(record.foo).toHaveBeenCalled()

  it 'should send a message to the record for each action', ->
    state = new State('astate', {entering: ['a', 'b', 'c', (r) -> r.foobar()]})
    record =
      a: ->
      b: ->
      c: ->
      foobar: ->
    spyOn(record, 'a')
    spyOn(record, 'b')
    spyOn(record, 'c')
    spyOn(record, 'foobar')
    state.callAction('entering', record)
    expect(record.a).toHaveBeenCalled()
    expect(record.b).toHaveBeenCalled()
    expect(record.c).toHaveBeenCalled()
    expect(record.foobar).toHaveBeenCalled()

  it "should stop calling actions if one of them raises :halt_aasm_chain", ->
    state = new State('astate', {entering: ['a', 'b', 'c']})
    record =
      a: ->
      b: ->
      c: ->
    spyOn(record, 'a')
    spyOn(record, 'b').andThrow('halt_aasm_chain')
    spyOn(record, 'c')
    state.callAction('entering', record)
    expect(record.a).toHaveBeenCalled()
    expect(record.b).toHaveBeenCalled()
    expect(record.c).not.toHaveBeenCalled()

  it 'should call a function, passing in the record for an action if the action is present', ->
    state = new State('astate', {entering: (r) -> r.foobar()})
    record = foobar: ->
    spyOn(record, 'foobar')
    state.callAction('entering', record)
    expect(record.foobar).toHaveBeenCalled()
