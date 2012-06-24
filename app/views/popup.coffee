define [
  'jquery'
  'underscore'
  'backbone'
  'text!templates/popup.html'
  ], ($, _, Backbone, popupTemplate) ->
  
  class PopupView extends Backbone.View
    template: _.template(popupTemplate)
    
    events:
      'click .toggleButton': 'toggle'
    
    initialize: ->
      

    render: ->
      $(@el).html @template({})
      @
      
    toggle: ->
      alert 'toggled pressed!'
      
  PopupView