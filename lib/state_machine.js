var State, StateMachine, merge;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
merge = require('./helpers').merge;
State = require('./state');
module.exports = StateMachine = (function() {
  __extends(StateMachine, Object);
  StateMachine.machines = {};
  StateMachine.register = function(klass) {
    var sm;
    sm = new StateMachine('');
    this.machines[klass] = sm;
    return this[klass] = sm;
  };
  function StateMachine(name) {
    this.name = name;
    this.initialState = null;
    this.states = [];
    this.events = {};
    this.config = {};
  }
  StateMachine.prototype.clone = function() {
    var klone;
    klone = merge(this, {});
    klone.states = merge(this.states, {});
    klone.events = merge(this.events, {});
    return klone;
  };
  StateMachine.prototype.statesName = function() {
    return this.states.map(function(state) {
      return state.name;
    });
  };
  StateMachine.prototype.createState = function(name, options) {
    return this.states.push(new State(name, options));
  };
  return StateMachine;
})();