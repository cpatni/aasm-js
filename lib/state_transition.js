var StateTransition;
var __slice = Array.prototype.slice;
module.exports = StateTransition = (function() {
  function StateTransition(opts) {
    this.from = opts.from, this.to = opts.to, this.guard = opts.guard, this.onTransition = opts.onTransition;
    this.opts = opts;
  }
  StateTransition.prototype.perform = function() {
    var args, obj, _ref, _ref2;
    obj = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    switch (typeof this.guard) {
      case 'string':
        return (_ref = obj[this.guard]).call.apply(_ref, [obj].concat(__slice.call(args)));
      case 'function':
        return (_ref2 = this.guard).call.apply(_ref2, [null, obj].concat(__slice.call(args)));
      default:
        return true;
    }
  };
  StateTransition.prototype.execute = function() {
    var args, obj, ot, _i, _len, _ref, _results;
    obj = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (Array.isArray(this.onTransition)) {
      _ref = this.onTransition;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ot = _ref[_i];
        _results.push(this._execute.apply(this, [obj, ot].concat(__slice.call(args))));
      }
      return _results;
    } else {
      return this._execute.apply(this, [obj, this.onTransition].concat(__slice.call(args)));
    }
  };
  StateTransition.prototype.equals = function(obj) {
    return this.from === obj.from && this.to === obj.to;
  };
  StateTransition.prototype.isFrom = function(value) {
    return this.from === value;
  };
  StateTransition.prototype.isTo = function(value) {
    return this.to === value;
  };
  StateTransition.prototype._execute = function() {
    var args, obj, onTransition, _ref;
    obj = arguments[0], onTransition = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    switch (typeof onTransition) {
      case 'string':
        return (_ref = obj[onTransition]).call.apply(_ref, [obj, obj].concat(__slice.call(args)));
      case 'function':
        try {
          return onTransition.call.apply(onTransition, [obj, obj].concat(__slice.call(args)));
        } catch (error) {
          return console.trace();
        }
    }
  };
  return StateTransition;
})();