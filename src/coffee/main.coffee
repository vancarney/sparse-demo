global = exports ? window
SparseDemo = global.SparseDemo = {} if !global.SparseDemo
( ( $ ) ->
  'use strict'
  $(document).ready =>
    # Use Mustache Style Template Tags
    _.templateSettings =
      interpolate : /\{\{(.+?)\}\}/g
    # basic rivets configuraton
    rivets.configure
      adapter:
        subscribe: (obj, keypath, callback)->
          obj.on 'change:' + keypath, callback
        unsubscribe: (obj, keypath, callback)->
          obj.off 'change:' + keypath, callback
        read: (obj, keypath)->
          obj.get keypath
        publish: (obj, keypath, value)->
          obj.set keypath, value
    # Application Entry Point
    new (SparseDemo.BaseView.extend
      el:"body"
      subviews:
        '#credentialsModal':class CredentialsModal extends SparseDemo.BaseView
          model:new (Backbone.Model.extend
            defaults:
              app_id:""
              rest_key:""
          )
          events:
            'click #close':'hide'
            'click #save':'setCredentials'
          hide:(evt)->
            evt.preventDefault() if evt
            @__rv.unbind()
            @__parent.off 'authOK'
            @__parent.off 'authFail'
            @$el.modal 'hide'
            false
          show:->
            @__rv = rivets.bind @el, access:@model
            @model.clear()
            @__parent.on 'authOK', => @hide()
            @__parent.on 'authFail', => @model.clear()
            @$el.css 'top', $(window).scrollTop()
            @$el.modal 'show'
          toggle:->
            @$el.modal 'toggle'
          setCredentials:(evt)->
            evt.preventDefault()
            @trigger 'credentialsSaved', @model.attributes
            false
          init:(o)->
      getAPIHeaders:->
        $.ajax
          type: 'HEAD'
          async: true
          url: window.location
          success: (mssg,txt,res)=>
            if ((app_id = res.getResponseHeader 'X-PARSE-APP-ID') == null) or ((rest_key = res.getResponseHeader 'X-PARSE-REST-KEY') == null)
              return @['#credentialsModal'].show()
            else
              @setCredentials app_id, rest_key
      childrenComplete : ->
        @['#credentialsModal'].on 'credentialsSaved', ((d)=> @setCredentials d.app_id, d.rest_key)
        @delegateEvents()
      getCredentials : ->
        return null if typeof (appId = (sparse.APP_ID || $.cookie 'PARSE_APP_ID')) == 'undefined' or typeof (restKey = (sparse.REST_KEY || $.cookie 'PARSE_REST_KEY')) == 'undefined'
        { app_id   : appId, rest_key : restKey}
      setCredentials:(appId, restKey)->
        if "#{appId}#{restKey}".match /^[a-z0-9]{80}$/i
          $.cookie 'PARSE_APP_ID',   sparse.APP_ID    = appId 
          $.cookie 'PARSE_REST_KEY', sparse.REST_KEY  = restKey
          @trigger 'authOK'
        else
          @trigger 'authFail'
      unsetCredentials : ->
        $.cookie 'PARSE_APP_ID', sparse.APP_ID = null
        $.cookie 'PARSE_REST_KEY', sparse.REST_KEY = null
      createView:(type)->
        type =  ($('div[data-viewid]').attr 'data-viewid') || "index"
        @view = new (@model.get type)
          el:$("div[data-viewid=#{type}]")
      init:(o)->
        global.app = @
        if (c = @getCredentials()) == null
          @getAPIHeaders()
        else
          @setCredentials c.app_id, c.rest_key
        @model = o.model if o? and o.model
        @createView() 
    )     
      model:new Backbone.Model
        index:SparseDemo.IndexView
)(jQuery)