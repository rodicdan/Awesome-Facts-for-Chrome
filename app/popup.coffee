# Configure require stuff
require.config
  paths:
    # Who doesn't need this?
    jquery: 'libs/jquery/jquery-1.7.1'
    
    # Require.js plugins
    text: 'libs/require/require-text'
    domReady: 'libs/require/domReady'
    order: 'libs/require/order'
    
    # Bootstrap goodness
    bootstrap: 'libs/bootstrap/bootstrap'
    
    # Javascript MVC
    underscore: 'libs/backbone/underscore'
    
    # Backbone and its localstorage helper
    backbone: 'libs/backbone/backbone'
    localstorage: 'libs/backbone/localstorage'
    
# Setup our app
require [
  'jquery'
  'backbone'
  'views/popup'
  'libs/iphone-style-checkboxes'
  ], ($, Backbone, PopupView) ->
  $ ->
    # show our popup content
    @view = new PopupView
    $('#wrapper').append @view.render().el
    
    # Set default slider position
    pluginEnabled = window.localStorage.getItem('pluginEnabled') == 'true'
    $(':checkbox').prop('checked', "checked") if pluginEnabled
    
    # Make checkbox a slider and listen for events
    $onOffBox = $(':checkbox').iphoneStyle
      onChange: (elem, value) ->
        # Save slider state and send result to tabs
        window.localStorage.setItem 'pluginEnabled', value.toString()
        result = value.toString() == 'true'
        window.FactsUtils.sendResponseToTabs result
        window.FactsUtils.updateBadge result
    
    # Attach handler for feedback link
    $('#feedback').click ->
      window.FactsUtils.sendEmail 'draco@dracoli.com', 
        'Awesome Facts Feedback'