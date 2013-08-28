global = exports ? window
SparseDemo = global.SparseDemo = {} if !global.SparseDemo
( ( $ ) ->
  'use strict'
  # Models View, handles UI controls for Collections Section of Index
  class SparseDemo.CollectionView extends SparseDemo.BaseView
    reset:->
      @collection.reset []
    init:(o)->
      @collection.on 'add remove change reset', => @$el.find('#submit_query').attr 'disabled', (@collection.length < 1)
    loadCollection:->
      options = @['form'].getSettings()
      opts = 
        reset: true
        error:(m,r,o)->
          @trigger 'loadingStop'
          console.log 'failed to fetch collection'
      @collection.fetch _.extend options, opts
    collection: new (class SparseDemo.TestCompanies extends sparse.Collection 
      model: class SparseDemo.TestCompany extends sparse.Model
    )
    childrenComplete:->
      @['form'].on 'load', (options={})=> @loadCollection options
      @
    subviews:
      'table' : class SparseDemo.CollectionTable extends SparseDemo.BaseView
        template: $( '#textCompaniesItem' ).html()
        setData:(data)->
          if data.length
            @$el.find('tbody tr').remove()
            _.each data, (v,k)=> @$el.find('tbody').append _.template @template, v.toJSON()
          else
            @$el.find('tbody tr').remove()
            @$el.find('tbody').append @__o_template
        init:(o)->
          @__o_template = @$el.find('tbody tr')
          @__parent.collection.on 'reset', (evt)=>
            @__parent.trigger 'loadingStop'
            @setData @__parent.collection.models
      'form': class SparseDemo.CollectionForm extends SparseDemo.BaseView
        getSettings:->
          opts =
            limit: Number @$el.find('#limit').val()
          opts.where = active:Boolean(active) if (active = @$el.find('#active').val())? and active != ""
          opts        
        events:
          #handle query submit button
          'click #submit_query' : (evt)->
            evt.preventDefault()
            @trigger 'load'
            false
)(jQuery)
