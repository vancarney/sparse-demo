global = exports ? window
SparseDemo = global.SparseDemo = {} if !global.SparseDemo
( ( $ ) ->
  'use strict'
  class SparseDemo.BaseView extends Backbone.View
    __children:[]
    __parent:{}
    render:->
      if typeof @subviews != 'undefined' and @subviews? and _.isObject @subviews
        _.each @subviews, ((view, selector)=>
          return if typeof view == 'undefined'
          _.each (@$el.find selector), (v,k)=>
            @__children.push (@[selector] = new view
              el: v
              __parent:@
            )
        )
        @delegateEvents()
      @childrenComplete()
    setElement:(el)->
      @$el = $(@el = el) if el
      @delegateEvents()
      @$el
    childrenComplete:->
      # stub for childrenComplete
    initialize:(o)->
      @setElement o.el if o? and o.el
      @__parent = o.__parent if o? and o.__parent
      if typeof @init == 'function'
        if o? then @init o else @init() 
      @render()
  class SparseDemo.APIFormView extends SparseDemo.BaseView
    subviews:
      # This View is injected onto every Demo Form API Button to force API Access Modal if no credentials have been provided
      '.api-btn': class SparseDemo.APIFormView extends SparseDemo.BaseView
        events:
          'click':'handleAPIButton'
        handleAPIButton:(evt)->
          evt.preventDefault();
          # check if crednetials are set
          if global.app.getCredentials() == null
            # cancel event and show Midal if no crednetials
            evt.stopImmediatePropagation();
            global.app['#credentialsModal'].show()
            false
)(jQuery)
