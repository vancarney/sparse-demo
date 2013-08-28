global = exports ? window
SparseDemo = global.SparseDemo = {} if !global.SparseDemo
( ( $ ) ->
  'use strict'
  # Models View, handles UI controls for Users Section of Index
  class SparseDemo.UserView extends SparseDemo.BaseView
    reset:->
      if !@['form'].model.isNew()
        if !sparse.SESSION_TOKEN
          @['form'].model.login @['form'].model.get( 'username' ), @['form'].model.get( 'password' ), 
            success:(m,r,o)=> @reset()
        else
          @['form'].model.destroy
            success:=>
              @['form'].model.clear()
              @['form'].model.set @['form'].__defaults
              @['form'].$el.find('#create_user').attr( 'disabled', false
              ).siblings().attr 'disabled', true
    subviews:
      'form': class SparseDemo.UserForm extends SparseDemo.APIFormView
        __defaults: 
          username:"a.user"
          password:"sParse"
        model:new (sparse.User) {username:"a.user", password:"sParse"}
        init:(o)->
          rivets.bind @el, user: @model
        events:
          #handle user creation button
          'click #create_user' : (evt)->
            @model.save null,
              success:(m,r,o)=>
                $(evt.target).attr 'disabled', true 
                @$el.find('#login_user').attr 'disabled', false
              error:(m,r,o)->
                console.log 'failed to create user'
          #handle user login button
          'click #login_user'  : (evt)->
            evt.preventDefault()
            @model.login @model.get( 'username' ), @model.get( 'password' ),
              success:(m,r,o)=>
                $(evt.target).attr 'disabled', true
                @$el.find('#logout_user').attr 'disabled', false
                @$el.find('#destroy_user').attr 'disabled', false
              error:(m,r,o)->
                console.log 'failed to login user'
            false
          #handle user logout button
          'click #logout_user' : (evt)->
            evt.preventDefault()
            @model.logout()
            @$el.find('#login_user').attr( 'disabled', false
            ).siblings().attr 'disabled', true
            false
          #handle user destroy button
          'click #destroy_user': (evt)->
            evt.preventDefault()
            @__parent.reset()
            false
)(jQuery)
