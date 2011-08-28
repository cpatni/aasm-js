AASM = require '../lib/aasm'

class AuthMachine
  AASM.include(this)

  #properties activationCode, activatedAt, deletedAt

  @aasmInitialState 'pending'
  @aasmState 'passive'
  @aasmState 'pending', enter: 'makeActivationCode'
  @aasmState 'active',  enter: 'doActivate'
  @aasmState 'suspended'
  @aasmState 'deleted', enter: 'doDelete', exit: 'doUndelete'

  @aasmEvent 'register', ->
    @transitions from: 'passive', to: 'pending', guard: (u) -> u.canRegister()

  @aasmEvent 'activate', ->
    @transitions from: 'pending', to: 'active'

  @aasmEvent 'suspend', ->
    @transitions from: ['passive', 'pending', 'active'], to: 'suspended'

  @aasmEvent 'delete', ->
    @transitions from: ['passive', 'pending', 'active', 'suspended'], to: 'deleted'

  @aasmEvent 'unsuspend', ->
    @transitions from: 'suspended', to: 'active',  guard: (u) -> u.hasActivated()
    @transitions from: 'suspended', to: 'pending', guard: (u) -> u.hasActivationCode()
    @transitions from: 'suspended', to: 'passive'

  constructor: () ->
    @aasmEnterInitialState()

  makeActivationCode: () ->
    @activationCode = 'moo'

  doActivate: () ->
    @activatedAt = Date.now()
    @activationCode = null

  doDelete: () ->
    @deletedAt = Date.now()

  doUndelete: () ->
    @deletedAt = false

  canRegister: ()->
    true

  hasActivated: () ->
    @activatedAt?

  hasActivationCode: () ->
    @activationCode?

describe [AuthMachine, 'authentication state machine'], ->
  describe "initialization", ->
    it 'should be in pending state', ->
      auth = new AuthMachine()
      expect(auth.aasmCurrentState()).toEqual('pending')

    it 'should have an activation code', ->
      auth = new AuthMachine()
      expect(auth.hasActivationCode()).toBeTruthy()
      expect(auth.activationCode).toNotEqual(null)

  describe 'when being unsuspended', ->
    it 'should be active if previously acticated', ->
      auth = new AuthMachine()
      auth.activate()
      auth.suspend()
      auth.unsuspend()
      expect(auth.aasmCurrentState()).toEqual('active')

    it 'should be pending if not previously activated, but an activation code is present', ->
      auth = new AuthMachine()
      auth.suspend()
      auth.unsuspend()
      expect(auth.aasmCurrentState()).toEqual('pending')

    it 'should be passive if not previously activated and there is no activation code', ->
      auth = new AuthMachine()
      auth.activationCode = null
      auth.suspend()
      auth.unsuspend()
      expect(auth.aasmCurrentState()).toEqual('passive')
