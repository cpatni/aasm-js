StateTransition = require '../lib/state_transition'

describe 'StateTransition', ->
  it 'should set from, to, and opts attr readers', ->
    opts = {from: 'foo', to: 'bar', guard: 'g'}
    st = new StateTransition(opts)
    expect(st.from).toEqual(opts.from)
    expect(st.to).toEqual(opts.to)
    expect(st.opts).toEqual(opts)

  it 'should pass equality check if from and to are the same', ->
    opts = {from: 'foo', to: 'bar', guard: 'g'}
    st = new StateTransition(opts)
    obj = {from: opts.from, to: opts.to}
    expect(st.equals(obj)).toBeTruthy()


  it 'should fail equality check if from are not the same', ->
    opts = {from: 'foo', to: 'bar', guard: 'g'}
    st = new StateTransition(opts)
    obj = {from: 'blah', to: opts.to}
    expect(st.equals(obj)).toBeFalsy()
    expect(st).toNotEqual(obj)

  describe '- when performing guard checks', ->
    it 'should return true of there is no guard', ->
      opts = {from: 'foo', to: 'bar'}
      st = new StateTransition(opts)
      expect(st.perform(null)).toBeTruthy()


    it 'should call the method on the object if guard is a string', ->
      opts = {from: 'foo', to: 'bar', guard: 'test'}
      st = new StateTransition(opts)
      object = test: ->
      spyOn(object, 'test')
      st.perform(object)
      expect(object.test).toHaveBeenCalled()

    it 'should call the proc passing the object if the guard is a function', ->
      opts = {from: 'foo', to: 'bar', guard: (o) -> o.test() }
      st = new StateTransition(opts)
      obj = test: ->
      spyOn(obj, 'test')
      st.perform(obj)
      expect(obj.test).toHaveBeenCalled()
