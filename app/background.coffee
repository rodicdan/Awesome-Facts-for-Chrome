class FactsList
  MINIMUM_FACTS_COUNT: 50 # until new fetch is required

  MAX_STORED: 200

  factsUrl: "http://simple-planet-5852.herokuapp.com/facts?format=json&count=80"
  
  factsIdentifier: 'factsList'

  readFactsIdentifier: 'factsRead'

  facts: JSON.parse(window.localStorage.getItem("factsList")) || []

  readFacts: JSON.parse(window.localStorage.getItem("factsRead")) || { "count": 0 }
  
  isEnabled: window.localStorage.getItem('pluginEnabled')
  
  _instance = null
  @instance: ->
    if not @._instance?
      _instance = new @
    _instance
    
  constructor: ->
    # Enable plugin if just installed and update badge
    pluginEnabled = window.localStorage.getItem('pluginEnabled')
    if pluginEnabled == null || pluginEnabled == 'true'
      pluginEnabled = true
      window.localStorage.setItem('pluginEnabled', true)
    else
      pluginEnabled = false
    window.FactsUtils.updateBadge pluginEnabled
    
    # Load facts if required
    @fetchFactsIfRequired()

  fetchFacts: (callback = null) ->
    console.log 'fetching facts'
    $.get @factsUrl, (data) =>
      if data?
        @facts = @facts.concat data
        console.log @facts
        @saveFacts()
        callback @facts if callback?

  fetchFactsIfRequired: ->
    console.log 'checking if fetch needed'
    @fetchFacts() if @facts.length < @MINIMUM_FACTS_COUNT

  getFact: ->
    @fetchFactsIfRequired()
    
    # Get facts until its not in our read facts
    targetFact = @facts.splice(0, 1)[0]
    console.log targetFact
    while @isReadFact(targetFact)
      targetFact = @facts.splice(0, 1)[0]
    
    # Store the id of the obtained unread fact fact
    @saveReadFact targetFact

    # Save facts since we removed one
    @saveFacts()
    targetFact

  saveFacts: ->
    window.localStorage.setItem @factsIdentifier, JSON.stringify(@facts)

  saveReadFacts: ->
    window.localStorage.setItem @readFactsIdentifier, JSON.stringify(@readFacts)

  saveReadFact: (fact) ->
    @readFacts[fact.id] = true
    @readFacts["count"] += 1
    @saveReadFacts()
    @clearReadFactsIfRequired()

  isReadFact: (fact) ->
    if @readFacts[fact.id]?
      return true
    return false

  clearReadFactsIfRequired: ->
    if @readFacts["count"] > @MAX_STORED
      @readFacts = { "count": 0 }
      @saveReadFacts()

FactsList.instance() # Set badge

# Respond any requests for plugin enable and getting facts
chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
  if request.action == 'getFact'
    sendResponse value: FactsList.instance().getFact()
  else if request.action == 'isEnabled'
    result = window.localStorage.getItem('pluginEnabled') == 'true'
    sendResponse value: result