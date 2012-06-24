define [
  'jquery'
  'underscore'
  'backbone'
  'text!templates/home.html'
  ], ($, _, Backbone, homeTemplate) ->
  
  class HomeView extends Backbone.View
    id: 'home'

    template: _.template(homeTemplate)

    initialize: (options)->

    render: ->
      $(@el).html @template
      @

  HomeView