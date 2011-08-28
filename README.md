= AASM.js - CoffeeScript state machines

This package contains AASM, a library for adding finite state machines to CoffeeScript classes.

AASM has the following features:

* States
* Machines
* Events
* Transitions

== Download

The latest AASM can currently be pulled from the git repository on github.

* http://github.com/rubyorchard/aasm.js/tree/master


== Installation

=== From npm repository

  % npm install aasm-js

== Simple Example

Here's a quick example highlighting some of the features.

  AASM = require 'aasm'

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


== A Slightly More Complex Example

This example uses a few of the more complex features available.

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

= Other Stuff
Based On:: Scott Barron aasm for ruby
Author::  Chandra Patni
License:: Original code Copyright 2011 by Chandra Patni.
          Released under an MIT-style license.  See the LICENSE  file
          included in the distribution.

== Warranty

This software is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantibility and fitness for a particular
purpose.