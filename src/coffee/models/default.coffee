global = exports ? window
if (typeof exports != 'undefined')
  _        = require('underscore')._
  Backbone = require 'backbone'
  jQuery   = require 'jQuery'
  {sparse}   = require '../sparse'
( ( $ ) ->
  'use strict'
  SparseDemo = global.SparseDemo = {} if !global.SparseDemo
  sparse.Model::nestCollection = (attributeName, nestedCollection) ->
    # setup nested references
    for item, i in nestedCollection
      @attributes[attributeName][i] = (nestedCollection.at i).attributes
    # create empty arrays if none
    nestedCollection.bind 'add', (initiative) =>
      if !@get attributeName
        @attributes[attributeName] = []
      (@get attributeName).push initiative.attributes
    # remove arrays
    nestedCollection.bind 'remove', (initiative) =>
      updateObj = {}
      updateObj[attributeName] = _.without (@get attributeName), initiative.attributes 
      @set updateObj
    # return
    nestedCollection
  class SparseDemo.DefaultData extends sparse.Model
    url:->
      '/data.json'
    sync:(method, model, options)->
      Backbone.Model.prototype.sync.call @, method, model, options
    initialize:(o)->
      @bind 'change', =>
        # loop through our attributes whenever our data changes...
        _.each @attributes, (v,k)=>
          # each attribute should be an Array of Objects .. let's put those intocollections
          @[className = "#{k.charAt(0).toUpperCase()}#{k.substring 1, k.length}"] = @nestCollection className, new (sparse.Collection.extend 
            __parse_classname : className
            # each collection should have a distinct model that share's it's Parse ClassName
            model: sparse.Model.extend 
              __parse_classname : className
          # Apply the Object Array to our Collection
          )(v)
)(jQuery)
