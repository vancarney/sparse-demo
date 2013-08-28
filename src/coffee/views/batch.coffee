global = exports ? window
SparseDemo = global.SparseDemo = {} if !global.SparseDemo
( ( $ ) ->
  'use strict'
  class SparseDemo.BatchView extends SparseDemo.BaseView
    reset:->
      @collection.reset()
      @$el.find('textarea').val( '').trigger 'change'
    collection: new sparse.Batch()
    loadForm:->
      # we will now attempt to load out Default JSON Data from /data.json
      (models = new SparseDemo.DefaultData).fetch
        success:(model, response, options)=>
          # loop through our 'models' Model -- each attribute should be a Collection
          _.each (_.keys models.attributes), (v,k)=>
            # add each nested Collection to the Batch Collection
            @collection.add models[v].models
          @['form'].setData response
          # uncomment the following line to view the Batch Collection
          # console.log @collection
        # we failed to load /data.json
        error:(model, response, options)->
          console.log "error: #{JSON.stringify response}"
     sendForm:(data)->
       @trigger 'loadingStart'
       # save the batch model to the Parse API
       @collection.exec
         success:(m,r,o)=>
           # uncomment the following line to see each batch update as it comes through
           # console.log m
         complete:(m,r,o)=>
           @trigger 'loadingStop'
           @trigger 'defaultDataLoaded' if typeof (d=JSON.parse @['form'].getData())['TestCompanies'] != 'undefind' and d['TestCompanies'].length
           @__parent.collection.destroy _.flatten m
         error:(m,r,o)->
           @trigger 'loadingStop'
           console.log m
    childrenComplete:->
      @['form'].on 'load', (evt)=> @loadForm()
      @['form'].on 'send', (evt,data)=> @sendForm data
    subviews:
      'form':class SparseDemo.BatchForm extends SparseDemo.APIFormView
        events:
          'change textarea':'onDataChanged'
          'click #load':'loadClicked'
          'click #send':'sendClicked'
        loadClicked:(evt)->
          evt.preventDefault()
          @trigger 'load'
          false
        sendClicked:(evt)->
          evt.preventDefault()
          @trigger 'send', @getData()
          false
        onDataChanged:(evt)->
          @$el.find('#send').attr 'disabled', ((d = @getData()).length == 0)
        setData:(d)->
          (t = @$el.find('textarea')).val JSON.stringify d, null, 2
          t.trigger 'change'
        getData:->
          @$el.find('textarea').val()
)(jQuery)
