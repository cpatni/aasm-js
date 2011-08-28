var State, capitalize, compact, count, del, ends, extend, flatten, last, merge, starts, _ref;
_ref = require('./helpers'), starts = _ref.starts, ends = _ref.ends, compact = _ref.compact, count = _ref.count, merge = _ref.merge, extend = _ref.extend, flatten = _ref.flatten, del = _ref.del, last = _ref.last, capitalize = _ref.capitalize;
module.exports = State = (function() {
  var _callAction;
  function State(name, options) {
    if (options == null) {
      options = {};
    }
    this.name = name;
    this.update(options);
  }
  State.prototype.equals = function(state) {
    return this["this"].name === state;
  };
  State.prototype.callAction = function(action, record) {
    var anAction, _i, _len, _results;
    action = this.options[action];
    if (Array.isArray(action)) {
      try {
        _results = [];
        for (_i = 0, _len = action.length; _i < _len; _i++) {
          anAction = action[_i];
          _results.push(_callAction(anAction, record));
        }
        return _results;
      } catch (HaltAasmChain) {

      }
    } else {
      return _callAction(action, record);
    }
  };
  State.prototype.forSelect = function() {
    return [this.displayName, this.name];
  };
  State.prototype.update = function(options) {
    if (options == null) {
      options = {};
    }
    if (options.display) {
      this.displayName = del(options, 'display');
    } else {
      this.displayName = capitalize(this.name.replace(/_/g, ' '));
    }
    this.options = options;
    return this;
  };
  _callAction = function(action, record) {
    switch (typeof action) {
      case 'string':
        return record[action].call(record);
      case 'function':
        return action.call(action, record);
    }
  };
  return State;
})();