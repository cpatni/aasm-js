var AASM, Event, StateMachine;
var __slice = Array.prototype.slice;
StateMachine = require('./state_machine');
Event = require('./event');
module.exports = AASM = (function() {
  var ClassMethods, PrototypeMethods;
  function AASM() {}
  ClassMethods = {
    aasmInitialState: function(initialState) {
      if (initialState) {
        return StateMachine[this].initialState = initialState;
      } else {
        return StateMachine[this].initialState;
      }
    },
    aasmState: function(name, options) {
      var isMethod, sm;
      if (options == null) {
        options = {};
      }
      sm = StateMachine[this];
      sm.createState(name, options);
      if (!sm.initialState) {
        sm.initialState = name;
      }
      isMethod = "is" + (name.substr(0, 1).toUpperCase()) + (name.substr(1));
      return this.prototype[isMethod] = function() {
        return this.aasmCurrentState() === name;
      };
    },
    aasmEvent: function(name, options, block) {
      var sm;
      if (options == null) {
        options = {};
      }
      if (typeof options === 'function') {
        block = options;
        options = {};
      }
      sm = StateMachine[this];
      if (!sm.events[name]) {
        sm.events[name] = new Event(name, options, block);
      }
      this.prototype[name] = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return this.aasmFireEvent.apply(this, [name, false].concat(__slice.call(args)));
      };
      return this.prototype["" + name + "AndSave"] = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return this.aasmFireEvent.apply(this, [name, true].concat(__slice.call(args)));
      };
    },
    aasmStates: function() {
      return StateMachine[this].states;
    },
    aasmStatesName: function() {
      return StateMachine[this].statesName();
    },
    aasmEvents: function() {
      return StateMachine[this].events;
    },
    aasmStatesForSelect: function() {
      console.log(this.aasmStates());
      return StateMachine[this].states.map(function(state) {
        console.log("..AAAAA....", state);
        return state.forSelect();
      });
    }
  };
  PrototypeMethods = {
    aasmCurrentState: function() {
      if (this._aasmCurrentState) {
        return this._aasmCurrentState;
      }
      if (this.aasmReadState != null) {
        this._aasmCurrentState = this.aasmReadState();
      }
      if (this._aasmCurrentState) {
        return this._aasmCurrentState;
      }
      return this.aasmEnterInitialState();
    },
    aasmEnterInitialState: function() {
      var state, stateName;
      stateName = this.aasmDetermineStateName(this.constructor.aasmInitialState());
      state = this.aasmStateObjectForState(stateName);
      state.callAction('beforeEnter', this);
      state.callAction('enter', this);
      this._aasmCurrentState = stateName;
      state.callAction('afterEnter', this);
      return stateName;
    },
    aasmEventsForCurrentState: function() {
      return this.aasmEventsForState(this.aasmCurrentState());
    },
    aasmEventsForState: function(state) {
      var events, name, value, values;
      values = (function() {
        var _ref, _results;
        _ref = this.constructor.aasmEvents();
        _results = [];
        for (name in _ref) {
          value = _ref[name];
          _results.push(value);
        }
        return _results;
      }).call(this);
      events = values.filter(function(event) {
        return event.isTransitionsFromState(state);
      });
      return events.map(function(event) {
        return event.name;
      });
    },
    setAasmCurrentStateWithPersistence: function(state) {
      var saveSuccess;
      saveSuccess = true;
      if (this.aasmWriteState != null) {
        saveSuccess = this.aasmWriteState(state);
      }
      if (saveSuccess) {
        this._aasmCurrentState = state;
      }
      return saveSuccess;
    },
    setAasmCurrentState: function(state) {
      if (this.aasmWriteStateWithoutPersistence != null) {
        this.aasmWriteStateWithoutPersistence(state);
      }
      return this._aasmCurrentState = state;
    },
    aasmDetermineStateName: function(state) {
      switch (typeof state) {
        case 'string':
          return state;
        case 'function':
          return state.call(this, this);
        default:
          throw {
            name: "NotImplementedError",
            message: "Unrecognized state-type given.  Expected String, or Function."
          };
      }
    },
    aasmStateObjectForState: function(name) {
      var obj;
      obj = this.constructor.aasmStates().filter(function(s) {
        return s.name === name;
      });
      if (!obj) {
        throw {
          name: "UndefinedState",
          message: "State :" + name + " doesn't exist"
        };
      }
      return obj[0];
    },
    aasmFireEvent: function() {
      var args, event, name, newState, newStateName, oldState, persist, persistSuccessful;
      name = arguments[0], persist = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      event = this.constructor.aasmEvents()[name];
      try {
        oldState = this.aasmStateObjectForState(this.aasmCurrentState());
        oldState.callAction('exit', this);
        event.callAction('before', this);
        newStateName = event.fire.apply(event, [this].concat(__slice.call(args)));
        if (newStateName !== null) {
          newState = this.aasmStateObjectForState(newStateName);
          oldState.callAction('beforeExit', this);
          newState.callAction('beforeEnter', this);
          newState.callAction('enter', this);
          persistSuccessful = true;
          if (persist) {
            persistSuccessful = this.setAasmCurrentStateWithPersistence(newStateName);
            if (persistSuccessful) {
              event.executeSuccessCallback(this);
            }
          } else {
            this.setAasmCurrentState(newStateName);
          }
          if (persistSuccessful) {
            oldState.callAction('afterExit', this);
            newState.callAction('afterEnter', this);
            event.callAction('after', this);
            if (this.aasmEventFired) {
              this.aasmEventFired(name, oldState.name, this.aasmCurrentState());
            }
          } else {
            if (this.aasmEventFailed) {
              this.aasmEventFailed(name, oldState.name);
            }
          }
          return persistSuccessful;
        } else {
          if (this.aasmEventFailed) {
            this.aasmEventFailed(name, oldState.name);
          }
          return false;
        }
      } catch (e) {
        return event.executeErrorCallback(this, e);
      }
    }
  };
  AASM.include = function(klass) {
    var method, name;
    for (name in ClassMethods) {
      method = ClassMethods[name];
      klass[name] = method;
    }
    for (name in PrototypeMethods) {
      method = PrototypeMethods[name];
      klass.prototype[name] = method;
    }
    return StateMachine.register(klass);
  };
  return AASM;
})();