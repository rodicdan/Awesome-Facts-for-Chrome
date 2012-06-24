class FactsUtils
  
  # Send response to all opened tabs
  sendResponseToTabs: (value) ->
    chrome.windows.getAll "populate": true, (windows)->
      for window in windows
        for tab in window.tabs
          chrome.tabs.sendRequest tab.id,
            action: 'pluginChanged'
            value: value, (response) ->
        
  updateBadge: (value) ->
    if value == true
      chrome.browserAction.setBadgeBackgroundColor
        color: '#4E970A'
      chrome.browserAction.setBadgeText
        text: 'on'
    else
      chrome.browserAction.setBadgeBackgroundColor
        color: '#9C1A1A'
      chrome.browserAction.setBadgeText
        text: 'off'
        
  sendEmail: (email, subject, body) ->
    action_url = "mailto:#{email}?"
    if subject.length > 0
      action_url += "subject=#{encodeURIComponent(subject)}&"
    if body? && body.length > 0
      action_url += "body=#{encodeURIComponent(body)}"
    chrome.windows.create
      url: action_url
      type: 'popup'

window.FactsUtils = new FactsUtils()