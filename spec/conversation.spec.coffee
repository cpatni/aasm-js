Conversation = require './conversation'

describe 'Conversation', ->

  it '.aasm_states should contain all of the states', ->
    expect(Conversation.aasmStatesName()).toEqual(['needsAttention', 'read', 'closed', 'awaitingResponse', 'junk'])



