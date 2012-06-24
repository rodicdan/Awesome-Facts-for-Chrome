// Generated by CoffeeScript 1.3.3
(function() {
  var FactsList;

  FactsList = (function() {
    var _instance;

    FactsList.prototype.MINIMUM_FACTS_COUNT = 50;

    FactsList.prototype.MAX_STORED = 200;

    FactsList.prototype.factsUrl = "http://simple-planet-5852.herokuapp.com/facts?format=json&count=80";

    FactsList.prototype.factsIdentifier = 'factsList';

    FactsList.prototype.readFactsIdentifier = 'factsRead';

    FactsList.prototype.facts = JSON.parse(window.localStorage.getItem("factsList")) || [];

    FactsList.prototype.readFacts = JSON.parse(window.localStorage.getItem("factsRead")) || {
      "count": 0
    };

    FactsList.prototype.isEnabled = window.localStorage.getItem('pluginEnabled');

    _instance = null;

    FactsList.instance = function() {
      if (!(this._instance != null)) {
        _instance = new this;
      }
      return _instance;
    };

    function FactsList() {
      var pluginEnabled;
      pluginEnabled = window.localStorage.getItem('pluginEnabled');
      if (pluginEnabled === null || pluginEnabled === 'true') {
        pluginEnabled = true;
        window.localStorage.setItem('pluginEnabled', true);
      } else {
        pluginEnabled = false;
      }
      window.FactsUtils.updateBadge(pluginEnabled);
      this.fetchFactsIfRequired();
    }

    FactsList.prototype.fetchFacts = function(callback) {
      var _this = this;
      if (callback == null) {
        callback = null;
      }
      console.log('fetching facts');
      return $.get(this.factsUrl, function(data) {
        if (data != null) {
          _this.facts = _this.facts.concat(data);
          console.log(_this.facts);
          _this.saveFacts();
          if (callback != null) {
            return callback(_this.facts);
          }
        }
      });
    };

    FactsList.prototype.fetchFactsIfRequired = function() {
      console.log('checking if fetch needed');
      if (this.facts.length < this.MINIMUM_FACTS_COUNT) {
        return this.fetchFacts();
      }
    };

    FactsList.prototype.getFact = function() {
      var targetFact;
      this.fetchFactsIfRequired();
      targetFact = this.facts.splice(0, 1)[0];
      console.log(targetFact);
      while (this.isReadFact(targetFact)) {
        targetFact = this.facts.splice(0, 1)[0];
      }
      this.saveReadFact(targetFact);
      this.saveFacts();
      return targetFact;
    };

    FactsList.prototype.saveFacts = function() {
      return window.localStorage.setItem(this.factsIdentifier, JSON.stringify(this.facts));
    };

    FactsList.prototype.saveReadFacts = function() {
      return window.localStorage.setItem(this.readFactsIdentifier, JSON.stringify(this.readFacts));
    };

    FactsList.prototype.saveReadFact = function(fact) {
      this.readFacts[fact.id] = true;
      this.readFacts["count"] += 1;
      this.saveReadFacts();
      return this.clearReadFactsIfRequired();
    };

    FactsList.prototype.isReadFact = function(fact) {
      if (this.readFacts[fact.id] != null) {
        return true;
      }
      return false;
    };

    FactsList.prototype.clearReadFactsIfRequired = function() {
      if (this.readFacts["count"] > this.MAX_STORED) {
        this.readFacts = {
          "count": 0
        };
        return this.saveReadFacts();
      }
    };

    return FactsList;

  })();

  FactsList.instance();

  chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
    var result;
    if (request.action === 'getFact') {
      return sendResponse({
        value: FactsList.instance().getFact()
      });
    } else if (request.action === 'isEnabled') {
      result = window.localStorage.getItem('pluginEnabled') === 'true';
      return sendResponse({
        value: result
      });
    }
  });

}).call(this);
