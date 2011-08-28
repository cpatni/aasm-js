var Event, StateTransition, flatten, merge, _ref;
var __slice = Array.prototype.slice;
StateTransition = require('./state_transition');
_ref = require('./helpers'), merge = _ref.merge, flatten = _ref.flatten;
module.exports = Event = (function() {
  function Event(name, options, callback) {
    if (options == null) {
      options = {};
    }
    this.name = name;
    this._transitions = [];
    this.update(options, callback);
  }
  Event.prototype.fire = function() {
    var aasmCurrentState, args, nextState, obj, toState, transition, transitions, _i, _len;
    obj = arguments[0], toState = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    if (toState == null) {
      toState = null;
    }
    aasmCurrentState = typeof obj.aasmCurrentState === 'function' ? obj.aasmCurrentState() : obj.aasmCurrentState;
    transitions = this._transitions.filter(function(t) {
      return t.from === aasmCurrentState;
    });
    if (transitions.length === 0) {
      throw {
        name: "InvalidTransition",
        message: "Event '" + this.name + "' cannot transition from '" + aasmCurrentState + "'"
      };
    }
    nextState = null;
    for (_i = 0, _len = transitions.length; _i < _len; _i++) {
      transition = transitions[_i];
      if (toState && flatten([transition.to]).indexOf(toState) < 0) {
        continue;
      }
      if (transition.perform.apply(transition, [obj].concat(__slice.call(args)))) {
        nextState = toState != null ? toState : flatten([transition.to])[0];
        transition.execute.apply(transition, [obj].concat(__slice.call(args)));
        break;
      }
    }
    return nextState;
  };
  Event.prototype.isTransitionsFromState = function(state) {
    return this._transitions.some(function(t) {
      return t.from === state;
    });
  };
  Event.prototype.transitionsFromState = function(state) {
    return this._transitions.filter(function(t) {
      return t.from === state;
    });
  };
  Event.prototype.callAction = function(action, record) {
    var anAction, _i, _len, _results;
    action = this.options[action];
    if (Array.isArray(action)) {
      _results = [];
      for (_i = 0, _len = action.length; _i < _len; _i++) {
        anAction = action[_i];
        _results.push(this._callAction(anAction, record));
      }
      return _results;
    } else {
      return this._callAction(action, record);
    }
  };
  Event.prototype.equals = function(event) {
    return this.name === event.name;
  };
  Event.prototype.update = function(options, block) {
    if (options == null) {
      options = {};
    }
    if (options.success) {
      this.success = options.success;
    }
    if (options.error) {
      this.error = options.error;
    }
    if (block) {
      block.call(this);
    }
    this.options = options;
    return this;
  };
  Event.prototype.executeSuccessCallback = function(obj, success) {
    var callback, meth, _i, _len, _results;
    if (success == null) {
      success = null;
    }
    callback = success != null ? success : this.success;
    switch (typeof callback) {
      case 'string':
        return obj[callback].call(obj);
      case 'function':
        try {
          return callback.call(obj, obj);
        } catch (error) {
          return console.log(error);
        }
        break;
      default:
        if (Array.isArray(callback)) {
          _results = [];
          for (_i = 0, _len = callback.length; _i < _len; _i++) {
            meth = callback[_i];
            _results.push(this.executeSuccessCallback(obj, meth));
          }
          return _results;
        } else {
          return "Unknow type " + callback;
        }
    }
  };
  Event.prototype.executeErrorCallback = function(obj, error, errorCallback) {
    var callback, meth, _i, _len, _results;
    if (errorCallback == null) {
      errorCallback = null;
    }
    callback = errorCallback || this.error;
    if (!callback) {
      throw error;
    }
    switch (typeof callback) {
      case 'string':
        if (!obj[callback]) {
          throw {
            name: "NoMethodError",
            message: "No such method " + callback
          };
        }
        return obj[callback].call(obj, error);
      case 'function':
        return callback.call(obj, error);
      default:
        if (Array.isArray(callback)) {
          _results = [];
          for (_i = 0, _len = callback.length; _i < _len; _i++) {
            meth = callback[_i];
            _results.push(this.executeErrorCallback(obj, error, meth));
          }
          return _results;
        } else {
          return "Unknow type " + callback;
        }
    }
  };
  Event.prototype._callAction = function(action, record) {
    switch (typeof action) {
      case 'string':
        return record[action].call(record);
      case 'function':
        return action.call(record);
    }
  };
  Event.prototype.transitions = function(transOpts) {
    var from, _i, _len, _ref2, _results;
    if (transOpts != null) {
      if (Array.isArray(transOpts.from)) {
        _ref2 = transOpts.from;
        _results = [];
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          from = _ref2[_i];
          _results.push(this._transitions.push(new StateTransition(merge(transOpts, {
            from: from
          }))));
        }
        return _results;
      } else {
        return this._transitions.push(new StateTransition(transOpts));
      }
    } else {
      return this._transitions;
    }
  };
  return Event;
})();