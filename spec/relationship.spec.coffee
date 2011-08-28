AASM = require '../lib/aasm'
class Relationship
  AASM.include(this)

  @aasmInitialState (relationship) ->
    if relationship.isStrictlyForFun() then 'intimate' else 'dating'

  @aasmState 'dating',   {enter: 'makeHappy', exit: 'makeDepressed'}
  @aasmState 'intimate', {enter: 'makeVeryHappy', exit: 'neverSpeakAgain'}
  @aasmState 'married',  {enter: 'makeHappy', exit: 'buyExoticCarAndWearACombover'}

  @aasmEvent 'getIntimate', ->
    @transitions to: 'intimate', from: ['dating'], guard: 'isDrunk'
  @aasmEvent 'getMarried', ->
    @transitions to: 'married', from: ['dating', 'married'], guard: 'isWillingToGiveUpManhood'

  isStrictlyForFun: ->
  isDrunk: ->
  isWillingToGiveUpManhood: ->
  makeHappy: ->
  makeDepressed: ->
  makeVeryHappy: ->
  neverSpeakAgain: ->
  giveUpIntimacy: ->
  buyExoticCarAndWearACombover: ->
