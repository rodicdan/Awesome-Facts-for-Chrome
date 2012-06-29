class FactsList
  MINIMUM_FACTS_COUNT: 50 # until new fetch is required

  MAX_STORED: 200

  factsUrl: 'http://simple-planet-5852.herokuapp.com/facts?format=json&count=80'
  
  factsIdentifier: 'factsList'

  readFactsIdentifier: 'factsRead'

  # Defaults
  facts: []
  readFacts: { 'count': 0 }
  isEnabled: true
  
  _instance = null
  @instance: ->
    _instance ?= new @
    
  constructor: ->
    # Enable plugin if just installed and update badge
    @isEnabled = window.localStorage.getItem('pluginEnabled') || @isEnabled
    if @isEnabled == true || @isEnabled == 'true'
      @isEnabled = true
      window.localStorage.setItem('pluginEnabled', true) # Save default
    else
      @isEnabled = false
    window.FactsUtils.updateBadge @isEnabled
    
    # Load existing data
    @facts = JSON.parse(window.localStorage.getItem("factsList")) || @facts
    @readFacts = JSON.parse(window.localStorage.getItem("factsRead")) || @readFacts
    
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
    if @readFacts[fact.id]? then true else false
    
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