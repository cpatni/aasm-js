# This file contains the common helper functions that we'd like to share among
# the **Lexer**, **Rewriter**, and the **Nodes**. Merge objects, flatten
# arrays, count characters, that sort of thing.

# Peek at the beginning of a given string to see if it matches a sequence.
exports.starts = (string, literal, start) ->
  literal is string.substr start, literal.length

# Peek at the end of a given string to see if it matches a sequence.
exports.ends = (string, literal, back) ->
  len = literal.length
  literal is string.substr string.length - len - (back or 0), len

# Trim out all falsy values from an array.
exports.compact = (array) ->
  item for item in array when item

# Count the number of occurrences of a string in a string.
exports.count = (string, substr) ->
  num = pos = 0
  return 1/0 unless substr.length
  num++ while pos = 1 + string.indexOf substr, pos
  num

# Merge objects, returning a fresh copy with attributes from both sides.
# Used every time `Base#compile` is called, to allow properties in the
# options hash to propagate down the tree without polluting other branches.
exports.merge = (options, overrides) ->
  extend (extend {}, options), overrides

# Extend a source object with the properties of another object (shallow copy).
extend = exports.extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

# Return a flattened version of an array.
# Handy for getting a list of `children` from the nodes.
exports.flatten = flatten = (array) ->
  flattened = []
  for element in array
    if element instanceof Array
      flattened = flattened.concat flatten element
    else
      flattened.push element
  flattened

# Delete a key from an object, returning the value. Useful when a node is
# looking for a particular method in an options hash.
exports.del = (obj, key) ->
  val =  obj[key]
  delete obj[key]
  val

# Gets the last item of an array(-like) object.
exports.last = (array, back) -> array[array.length - (back or 0) - 1]

'''
* @method capitalize()
* @returns String
* @short Capitalizes the first character in the string.
* @example
*
*   'hello'.capitalize()              -> 'Hello'
*   'why hello there...'.capitalize() -> 'Why hello there...'
'''
capitalize = exports.capitalize = (string) ->
  string.substr(0,1).toUpperCase() + string.substr(1).toLowerCase()

"""
/***
 * @method dasherize()
 * @returns String
 * @short Converts underscores and camel casing to hypens.
 * @example
 *
 *   'a_farewell_to_arms'.dasherize() -> 'a-farewell-to-arms'
 *   'capsLock'.dasherize()           -> 'caps-lock'
 *
 ***/

"""
dasherize = exports.dasherize = (string) ->
  string.replace(/([a-z])([A-Z])/g, '$1-$2').replace(/_/g, '-').toLowerCase()

"""
/***
 * @method underscore()
 * @returns String
 * @short Converts hyphens and camel casing to underscores.
 * @example
 *
 *   'a-farewell-to-arms'.underscore() -> 'a_farewell_to_arms'
 *   'capsLock'.underscore()           -> 'caps_lock'
 *
 ***/
"""

exports.underscore = (string) ->
  string.replace(/([a-z])([A-Z])/g, '$1_$2').replace(/-/g, '_').toLowerCase()

"""
/***
 * @method camelize([first] = true)
 * @returns String
 * @short Converts underscores and hyphens to camel case. If [first] is true the first letter will also be capitalized.
 * @example
 *
 *   'caps_lock'.camelize()              -> 'CapsLock'
 *   'moz-border-radius'.camelize()      -> 'MozBorderRadius'
 *   'moz-border-radius'.camelize(false) -> 'mozBorderRadius'
 *
 ***/

"""
exports.camelize = (string, first) ->
  parts = dasherize(string).split('-')
  text = for part, i in parts
    if first is false and i is 0
      part.toLowerCase()
    else
      part.substr(0, 1).toUpperCase() + part.substr(1).toLowerCase()
  text.join('')

'''
/***
 * @method words([fn])
 * @returns Array
 * @short Runs callback [fn] against each word in the string. Returns an array of words.
 * @extra A "word" here is defined as any sequence of non-whitespace characters.
 * @example
 *
 *   'broken wear'.words() -> ['broken','wear']
 *   'broken wear'.words(function(w) {
 *     // Called twice: "broken", "wear"
 *   });
 *
 ***/
'''

words = exports.words = (string, fn) ->
  parts = string.trim().split(/\s+/)
  if fn? then parts.map(fn) else parts


'''
/***
 * @method titleize()
 * @returns String
 * @short Capitalizes all first letters.
 * @example
 *
 *   'what a title'.titleize() -> 'What A Title'
 *   'no way'.titleize()       -> 'No Way'
 *
 ***/
'''
exports.titleize = (string) ->
  words(string, (s) -> capitalize(s)).join(' ')

