# Another Cakefile made with love by ezcake v0.7
# require Node::FS
fs = require 'fs'
# require Node::Util
{debug, error, log, print} = require 'util'
# import Spawn and Exec from child_process
{spawn, exec, execFile}=require 'child_process'
# try to import the Which module
try
  which = (require 'which').sync
catch err
  if process.platform.match(/^win/)?
    error 'The which module is required for windows. try "npm install which"'
  which = null
# colors
green = "\u001b[0;32m"
reset = "\u001b[0;0m"
# paths object for module invocation reference
paths={
  "assets": [
    "src/assets",
    "demo"
  ],
  "coffee": [
    "demo/javascript",
    "src/coffee"
  ],
  "scss": [
    'demo/css/'
    'src/scss/'
  ],
  "jade": [
    "src/jade",
    "demo",
    "src/jade/templates",
    "src/jade/include"
  ]
}
# file extensions for watching
exts='coffee|jade'
# Begin Callback Handlers
# Callback From 'coffee'
coffeeCallback=()->

# Callback From 'docco'
doccoCallback=()->

sassCallback=()->
  exec 'rm -rf ../sparse-pages/demo; cp -rf demo ../sparse-pages'
# Begin Tasks
# ## *build*
# Compiles Sources
task 'build', 'Compiles Sources', ()-> build -> log ':)', green
build = ()->
  # From Command 'assets'
  #  Copies Assets from src directory in build directory 
  exec "cp -r src/assets/. demo"
  # From Module 'coffee'
  # Enable coffee-script compiling
  launch 'coffee', (['-c', '-b', '-o' ].concat paths.coffee), coffeeCallback
  sass_opts = [ 'compile', "--sass-dir=#{paths.scss[1]}", "--css-dir=#{paths.scss[0]}"]
  launch 'compass', sass_opts, sassCallback
  # From Module 'jade'
  #  
  # exec "jade --path #{paths.jade[3]} -v --pretty --out #{paths.jade[2]}" 
  exec 'jade --path src/jade/include -v --pretty --out demo src/jade/templates'

task 'run', 'run demo in stand-alone web server (uses connect)', ()-> run()
run = ()->
  connect(
  ).use(connect.logger 'demo'
  ).use(connect.static 'demo'
  ).use( (req, res)-> res.end '' 
  ).listen 3000

# ## *watch*
# watch project src folders and build on change
task 'watch', 'watch project src folders and build on change', ()-> watch -> log ':)', green
watch = ()->
  

# ## *docs*
# Generate Documentation
task 'docs', 'Generate Documentation', ()-> docs -> log ':)', green
docs = ()->
  # From Module 'docco'
  #  
  if moduleExists 'docco' && paths? && paths.coffee
    walk paths.coffee[0], (err, paths) ->
      try
        launch 'docco', paths, doccoCallback()
      catch e
        error e
  

# ## *test*
# Runs your test suite.
task 'test', 'Runs your test suite.', (options=[],callback)-> test -> log ':)', green
test = (options=[],callback)->
  # From Module 'mocha'
  #  
  if moduleExists('mocha')
    if typeof options is 'function'
      callback = options
      options = []
    # add coffee directive
    options.push '--compilers'
    options.push 'coffee:coffee-script'
    
    launch 'mocha', options, callback

# Begin Helpers
#  
launch = (cmd, options=[], callback) ->
  cmd = which(cmd) if which
  app = spawn cmd, options
  app.stdout.pipe(process.stdout)
  app.stderr.pipe(process.stderr)
  app.on 'exit', (status) -> callback?() if status is 0#  
log = (message, color, explanation) -> 
  console.log color+message+reset+(explanation or '')#  
moduleExists = (name) ->
  try 
    require name 
  catch err 
    error name+ 'required: npm install '+name, red
    false#  
bin = (file) ->
  if file.match /.coffee$/
    fs.unlink file.replace(/.coffee$/, '.js')
    true
  else false#  
walk = (dir, done) ->
  # Directory Traversal
  results = []
  fs.readdir dir, (err, list) =>
    return done(err, []) if err
    pending = list.length
    return done(null, results) unless pending
    for name in list
      fs.stat dir+'/'+name, (e,stat)=>
        stat = null if e?
        if stat?.isDirectory()
          walk file, (err, res) =>
            results.push name for name in res
            done(null, results) unless --pending
        else
          results.push file
          done(null, results) unless --pending