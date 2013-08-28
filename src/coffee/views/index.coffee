global = exports ? window
SparseDemo = global.SparseDemo = {} if !global.SparseDemo
( ( $ ) ->
  'use strict'
  class SparseDemo.IndexView extends SparseDemo.BaseView
    collection:new sparse.Batch
    init:(o)->
      @collection.on 'reset add remove', => 
        @$el.find('#demo_reset').attr 'disabled', (@collection.length < 1)
    events:
      'click #demo_reset':(evt)->
        _.each @__children, (v,k) => 
          v.reset() if typeof  v.reset == 'function'
        $('body').mask ''
        setTimeout (=>
          $('body').unmask()
          @$el.find('#demo_reset').attr 'disabled', (@collection.length < 1)
          ), 8000
        @collection.exec
          complete:(m,r,o)=>
            $('body').unmask()
            @$el.find('#demo_reset').attr 'disabled', (@collection.length < 1)
          error:(m,r,o)=>
            $('body').unmask()
    childrenComplete:->
      _.each @__children, (v,k) => 
        v.on 'loadingStart', => $('body').mask ''
        v.on 'loadingStop',  => $('body').unmask()
      @['#batch'].on 'defaultDataLoaded', (evt)=> @['#collections'].loadCollection()
    subviews:
      '#models':SparseDemo.ModelView
      '#users':SparseDemo.UserView
      '#collections':SparseDemo.CollectionView
      '#batch':SparseDemo.BatchView
)(jQuery)