{exec, spawn} = require 'child_process'

handleError = (err) ->
  if err
    console.log "\n\033[1;36m=>\033[1;37m Remember that you need: coffee-script@1.1.2 and jasmine-node@1.1.6\033[0;37m\n"
    console.log err.stack


option '-v', '--verbose', 'Use jasmine verbose mode'

task 'build', 'Compile aasm-js Coffeescript source to Javascript', ->
  exec 'mkdir -p lib && coffee -c -o lib src', handleError

task 'test', 'Test the app', (options) ->

  jasmine = require 'jasmine-node'
  path = require('path')
  sys = require('sys')
  specFolder = path.join(__dirname, 'spec')
  console.log "\n\033[1;36m=>\033[1;37m Running spec from #{specFolder}\033[0;37m\n"
  
  isVerbose = options.verbose
  showColors = true
  extentions = 'js|coffee'
  
  
  jasmine.loadHelpersInFolder(specFolder, new RegExp("[-_]helper\.(js|coffee)$"))
  jasmine.executeSpecsInFolder specFolder, (runner, log) ->
    sys.print('\n');
    if runner.results().failedCount is 0
      process.exit(0);
    else
      process.exit(1);
  , isVerbose, showColors, new RegExp(".spec\\.(" + extentions + ")$", 'i')

  # invoke 'build'
  # args = [
  #   '--coffee'
  #   'spec'
  # ]
  # args.push '--verbose' if options.verbose
  # jasmine_node = spawn './node_modules/jasmine-node/bin/jasmine-node', args
  # jasmine_node.stdout.pipe(process.stdout, { end: false })
  # jasmine_node.stderr.pipe(process.stderr, { end: false })

task 'dev', 'Continuous compilation', ->
  # coffee = spawn 'coffee', '-wc --bare -o lib src/'.split(' ')
  coffee = spawn 'coffee', '-wc --bare -o lib src/'.split(' ')
  coffee.stdout.pipe(process.stdout, { end: false })
  coffee.stderr.pipe(process.stderr, { end: false })
