global = exports ? window
SparseDemo = global.SparseDemo = {} if !global.SparseDemo
( ( $ ) ->
  'use strict'
  # Models View, handles UI controls for Models Section of Index
  class SparseDemo.ModelView extends SparseDemo.BaseView
    reset:->
      @['form'].model.clear()
      @['form'].model.set @['form'].__defaults
    subviews:
      'form':class SparseDemo.ModelForm extends SparseDemo.APIFormView
        __defaults:
          name: 'Record One'
          description: 'This record created with sParse'
        init:(o)->
          @events = _.extend @events, ModelForm.__super__.events
          @delegateEvents()
          @model.on 'change', =>
            @$el.find('#create_model').attr( 'disabled', !(n=@model.isNew())
            ).siblings().attr 'disabled', n
          rivets.bind @el, model: @model
        model:new (class SparseClass extends sparse.Model)
        events:
          #handle record creation button
          'click #create_model' : (evt)->
            @model.save null,
              success:(m,r,o)=>
                @__parent.__parent.collection.destroy m
              error:(m,r,o)->
                console.log 'failed to create model'
          #handle record update button
          'click #update_model'  : (evt)->
            evt.preventDefault()
            @model.save
              success:(m,r,o)=>
              error:(m,r,o)->
                console.log 'failed to update model'
            false
          #handle record destroy button
          'click #destroy_model': (evt)->
            evt.preventDefault()
            @model.destroy
              success:(m,r,o)=>
                @__parent.__parent.collection.remove _.filter @__parent.__parent.collection.models, (o)=>
                  o.attributes.path.match new RegExp "\/#{@model.id}+$"
                @__parent.reset()
              error:(m,r,o)->
                console.log 'failed to destroy model'
            false
)(jQuery)