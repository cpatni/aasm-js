AASM = require '../lib/aasm'

module.exports = class Conversation
  AASM.include(this)

  @aasmInitialState 'needsAttention'

  @aasmState 'needsAttention'
  @aasmState 'read'
  @aasmState 'closed'
  @aasmState 'awaitingResponse'
  @aasmState 'junk'

  @aasmEvent 'newMessage', ()->

  @aasmEvent 'view', ()->
    @transitions {to: 'read', from: ['needsAttention']}

  @aasmEvent 'reply', ()->

  @aasmEvent 'close', ()->
    @transitions {to: 'closed', from: ['read', 'awaitingResponse']}

  @aasmEvent 'junk', ()->
    @transitions {to: 'junk', from: ['read']}

  @aasmEvent 'unjunk', ()->

