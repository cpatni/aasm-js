var capitalize, dasherize, extend, flatten, words;
exports.starts = function(string, literal, start) {
  return literal === string.substr(start, literal.length);
};
exports.ends = function(string, literal, back) {
  var len;
  len = literal.length;
  return literal === string.substr(string.length - len - (back || 0), len);
};
exports.compact = function(array) {
  var item, _i, _len, _results;
  _results = [];
  for (_i = 0, _len = array.length; _i < _len; _i++) {
    item = array[_i];
    if (item) {
      _results.push(item);
    }
  }
  return _results;
};
exports.count = function(string, substr) {
  var num, pos;
  num = pos = 0;
  if (!substr.length) {
    return 1 / 0;
  }
  while (pos = 1 + string.indexOf(substr, pos)) {
    num++;
  }
  return num;
};
exports.merge = function(options, overrides) {
  return extend(extend({}, options), overrides);
};
extend = exports.extend = function(object, properties) {
  var key, val;
  for (key in properties) {
    val = properties[key];
    object[key] = val;
  }
  return object;
};
exports.flatten = flatten = function(array) {
  var element, flattened, _i, _len;
  flattened = [];
  for (_i = 0, _len = array.length; _i < _len; _i++) {
    element = array[_i];
    if (element instanceof Array) {
      flattened = flattened.concat(flatten(element));
    } else {
      flattened.push(element);
    }
  }
  return flattened;
};
exports.del = function(obj, key) {
  var val;
  val = obj[key];
  delete obj[key];
  return val;
};
exports.last = function(array, back) {
  return array[array.length - (back || 0) - 1];
};
'* @method capitalize()\n* @returns String\n* @short Capitalizes the first character in the string.\n* @example\n*\n*   \'hello\'.capitalize()              -> \'Hello\'\n*   \'why hello there...\'.capitalize() -> \'Why hello there...\'';
capitalize = exports.capitalize = function(string) {
  return string.substr(0, 1).toUpperCase() + string.substr(1).toLowerCase();
};
"/***\n * @method dasherize()\n * @returns String\n * @short Converts underscores and camel casing to hypens.\n * @example\n *\n *   'a_farewell_to_arms'.dasherize() -> 'a-farewell-to-arms'\n *   'capsLock'.dasherize()           -> 'caps-lock'\n *\n ***/\n";
dasherize = exports.dasherize = function(string) {
  return string.replace(/([a-z])([A-Z])/g, '$1-$2').replace(/_/g, '-').toLowerCase();
};
"/***\n * @method underscore()\n * @returns String\n * @short Converts hyphens and camel casing to underscores.\n * @example\n *\n *   'a-farewell-to-arms'.underscore() -> 'a_farewell_to_arms'\n *   'capsLock'.underscore()           -> 'caps_lock'\n *\n ***/";
exports.underscore = function(string) {
  return string.replace(/([a-z])([A-Z])/g, '$1_$2').replace(/-/g, '_').toLowerCase();
};
"/***\n * @method camelize([first] = true)\n * @returns String\n * @short Converts underscores and hyphens to camel case. If [first] is true the first letter will also be capitalized.\n * @example\n *\n *   'caps_lock'.camelize()              -> 'CapsLock'\n *   'moz-border-radius'.camelize()      -> 'MozBorderRadius'\n *   'moz-border-radius'.camelize(false) -> 'mozBorderRadius'\n *\n ***/\n";
exports.camelize = function(string, first) {
  var i, part, parts, text;
  parts = dasherize(string).split('-');
  text = (function() {
    var _len, _results;
    _results = [];
    for (i = 0, _len = parts.length; i < _len; i++) {
      part = parts[i];
      _results.push(first === false && i === 0 ? part.toLowerCase() : part.substr(0, 1).toUpperCase() + part.substr(1).toLowerCase());
    }
    return _results;
  })();
  return text.join('');
};
'/***\n * @method words([fn])\n * @returns Array\n * @short Runs callback [fn] against each word in the string. Returns an array of words.\n * @extra A "word" here is defined as any sequence of non-whitespace characters.\n * @example\n *\n *   \'broken wear\'.words() -> [\'broken\',\'wear\']\n *   \'broken wear\'.words(function(w) {\n *     // Called twice: "broken", "wear"\n *   });\n *\n ***/';
words = exports.words = function(string, fn) {
  var parts;
  parts = string.trim().split(/\s+/);
  if (fn != null) {
    return parts.map(fn);
  } else {
    return parts;
  }
};
'/***\n * @method titleize()\n * @returns String\n * @short Capitalizes all first letters.\n * @example\n *\n *   \'what a title\'.titleize() -> \'What A Title\'\n *   \'no way\'.titleize()       -> \'No Way\'\n *\n ***/';
exports.titleize = function(string) {
  return words(string, function(s) {
    return capitalize(s);
  }).join(' ');
};