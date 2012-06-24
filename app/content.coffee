DEBUG = false

DLog = (content) ->
  console.log content if DEBUG
  
is_site_disabled = ->
  ignoredTags = [
    '#blueBar.fixed_elem'
    '#onegoogbar'
    '#gb'
    '#mngb'
    '.topbar .global-nav'
    '#navBar.fixed'
  ]
  DLog 'document ready called'
  selectors = ignoredTags.join(', ')
  if $(selectors).length > 0 then true else false

# Check out if we need to display a fact
chrome.extension.sendRequest
  action: 'isEnabled', (response) ->
    if response.value == true
      factMananger.showFact()

# Listen for plugin enabled changes
chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
  if request.action == 'pluginChanged'
    if request.value == true
      # Get fact for this page
      factMananger.showFact()
    else
      factMananger.hideFact()

factMananger =
  
  shareURL: "http://simple-planet-5852.herokuapp.com/share"
  
  hasFact: ->
    $('#draco-interesting-facts123').length > 0
    
  createNewFact: (fact) ->
    $factsBar = $('''
      <table id="draco-interesting-facts123">
      <tr>
        <td id="draco-interesting-facts-share">
          <iframe src=""></iframe>
        </td>
        <td id="draco-interesting-facts-fact123">
        </td>
        <td id="draco-interesting-facts-close123">
          &times;
        </td>
      </tr>
      </table>
      '''
    )

    DLog "fact content: #{fact.content}"
    
    # give content and share url to facts bar
    $factsBar.find('#draco-interesting-facts-fact123')
      .html fact.content
    $factsBar.find('#draco-interesting-facts-share iframe')
      .attr "src", "#{@shareURL}/#{fact.id}"
      
    # Handlers for sharing
    window.addEventListener 'message', @handleShareMessage, false
    
    # attach close action
    $factsBar.find('#draco-interesting-facts-close123').click ->
      $factsBar.remove()
    
    # attach fact to DOM
    $('html:first').prepend $factsBar
    
    # attach share action and tooltip
    $factsBar.find('#draco-interesting-facts-share').tooltip
      title: "Share Fact"
      placement: 'right'
      
    $factsBar
      
  showFact: ->
    if @hasFact()
      $('#draco-interesting-facts123').show()
    else
      chrome.extension.sendRequest
        action: 'getFact', (response) =>
          return if is_site_disabled()
          @createNewFact response.value
      
  hideFact: ->
    $('#draco-interesting-facts123').hide()
  
  handleShareMessage: (event) ->
    DLog event
    theIframe = $('#draco-interesting-facts-share iframe').contentWindow
    return if event.source != theIframe
    if event.data == "Awesome Fact Shared"
      DLog 'shared success'
      $('#draco-interesting-facts-share')
        .addClass("disabled")
        .tooltip('disable')
      noty
        text: 'Current Fact Shared :)'
        layout: 'topLeft'
        type: 'success'
        theme: 'noty_theme_facebook'
    else if event.data == "Awesome Fact Failed"
      DLog 'shared failed'
      @noty
        text: 'Sharing Failed :('
        layout: 'topLeft'
        type: 'error'
        theme: 'noty_theme_facebook'
    
# Remove facts if we have any annoy googlebars
$ -> 
  if is_site_disabled()
    $('#draco-interesting-facts123').remove()