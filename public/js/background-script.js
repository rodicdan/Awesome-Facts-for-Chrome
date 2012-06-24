
/**
 * In charges everything that is needed in the background
 * @author Draco Li
 */
window.draco_commerceFeeds = {
  
  defaultFeedUrl: '',
  isUpdating: false,
  
  /**
   * How long till we check for new feeds?
   */
  defaultFetchTime: 60 * 1000,
  
  /**
   * Called when plugin is enabled
   */
  __init: function() {
    var that = this;
    
    that.firstTimeConfigurations();
    
    // Start updates and set our defaultFeedsUrl
    that.startUpdatesChecking()
    
    // Set badge color
    chrome.browserAction.setBadgeBackgroundColor({ color: [126, 131, 145, 255] });
    
    // Registering for requested feeds updates
    chrome.extension.onRequest.addListener(function (request, sender, callback) {
      if (request.action == 'fetchFeeds') {
        that.fetchFeeds.call(that);
      }
    });
  },
  
  firstTimeConfigurations: function() {
    var that = this,
        isInstalled = window.storageManager.getItem('isInstalled'),
        userCategories = null;

    // Runs options page if extension is first installed
    if ( !isInstalled ) {
      
      /*
      // Open options page
      var optionsPageURL = chrome.extension.getURL('/views/options.html');
      chrome.tabs.create({url: optionsPageURL});
      window.localStorage.setItem('isInstalled', '1');
      */
      
      // Set default extension categories
      // The data is saved as json with the "userCategories" key
      userCategories = { 
        'DayOnBay': { 'max': 10, 'index': 1 }, 
        'Administrative': { 'max': 10, 'index': 2 }, 
        'ComSoc': { 'max': 10, 'index': 3, 'name': 'Commerce Society' },
        'Career': { 'max': 10, 'index': 4 }, 
        'General': { 'max': 10, 'index': 5 },
        'AMS': { 'max': 10, 'index': 6 },
        'ResearchPool': { 'max': 10, 'index': 7 , 'name': 'Research Pool' },
      };
      window.localStorage.setItem('userCategories', JSON.stringify(userCategories));
    }
  },
  
  /**
   * Periodically checks for new feeds
   */
  startUpdatesChecking: function() {
    var that = this;
    
    that.isUpdating = true;
    
    // Construct feed fetch url according to user categories
    that.constructFeedURL();
    
    var feedUpdates = function() {
      
      // This stop our periodic checks
      if ( that.isUpdating === false ) return;
      
      that.fetchFeeds();
      console.log('fetching new feeds');
      
      // This makes our loop. Set timeout is recommended.
      setTimeout(feedUpdates, that.defaultFetchTime);
    };
    feedUpdates(); // This starts it!
  },
  
  /**
   * Stop extension from checking new feeds
   */
  stopUpdatesChecking: function() {
    this.isUpdating = false;
  },
  
  /**
   * Send notification to user of new feeds
   */
  handleNewFeeds: function(newData) {
    var that = this,
        oldData = JSON.stringify(window.storageManager.getCachedFeeds());
		
		// First save cachedFeeds
		window.storageManager.setCachedFeeds(newData);

		// Only notify if our data is different
		newData = JSON.stringify(JSON.parse(newData));
		if ( newData !== oldData ) {
		  chrome.browserAction.setBadgeText({ text: "new" });
		  chrome.extension.sendRequest({action: "gotNewFeeds"}, function(){});
		}
  },
  
  /**
   * Gets feeds from server.
   * If url is provided, fetch that, else use defaultUrl
   */
  fetchFeeds: function connect(url) {
    var that = this,
        xhr = new XMLHttpRequest(),
        url = url || that.defaultFeedUrl;
    
    xhr.onreadystatechange = function(data) {
     if (xhr.readyState == 4) {
       if(xhr.status == 200) {
         var data = xhr.responseText;
         
         // Data handling is given to another function
         that.handleNewFeeds.call(that, data);
       }else {
         // No feeds retreived
       }
     } 
    }
    xhr.open('GET', url, true);
    xhr.send();
  },
  
  /**
	 * Construct the url to get content from server
	 */
	constructFeedURL: function() {
		var that = this,
		    userCategories = window.storageManager.getUserCategories();
				requestUrl = 'http://www.commercefeeds.dracoli.com/getFeeds.php?',
				firstTime = true;

		// Construct feed url according to user categories
		for (var category in userCategories) {
		  requestUrl += firstTime ? "" : "&";
		  firstTime = false;
			requestUrl += category + "=" + parseInt(userCategories[category]['max']);
		}
		console.log('feedURL: ' + requestUrl);
		that.defaultFeedUrl = requestUrl;
	}
};