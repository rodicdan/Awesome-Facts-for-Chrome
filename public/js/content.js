// Generated by CoffeeScript 1.3.3
(function() {
  var DEBUG, DLog, factMananger, is_site_disabled;

  DEBUG = false;

  DLog = function(content) {
    if (DEBUG) {
      return console.log(content);
    }
  };

  is_site_disabled = function() {
    var ignoredTags, selectors;
    ignoredTags = ['#blueBar.fixed_elem', '#onegoogbar', '#gb', '#mngb', '.topbar .global-nav', '#navBar.fixed'];
    DLog('document ready called');
    selectors = ignoredTags.join(', ');
    if ($(selectors).length > 0) {
      return true;
    } else {
      return false;
    }
  };

  chrome.extension.sendRequest({
    action: 'isEnabled'
  }, function(response) {
    if (response.value === true) {
      return factMananger.showFact();
    }
  });

  chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
    if (request.action === 'pluginChanged') {
      if (request.value === true) {
        return factMananger.showFact();
      } else {
        return factMananger.hideFact();
      }
    }
  });

  factMananger = {
    shareURL: "http://simple-planet-5852.herokuapp.com/share",
    hasFact: function() {
      return $('#draco-interesting-facts123').length > 0;
    },
    createNewFact: function(fact) {
      var $factsBar;
      $factsBar = $('<table id="draco-interesting-facts123">\n<tr>\n  <td id="draco-interesting-facts-share">\n    <iframe src=""></iframe>\n  </td>\n  <td id="draco-interesting-facts-fact123">\n  </td>\n  <td id="draco-interesting-facts-close123">\n    &times;\n  </td>\n</tr>\n</table>');
      DLog("fact content: " + fact.content);
      $factsBar.find('#draco-interesting-facts-fact123').html(fact.content);
      $factsBar.find('#draco-interesting-facts-share iframe').attr("src", "" + this.shareURL + "/" + fact.id);
      window.addEventListener('message', this.handleShareMessage, false);
      $factsBar.find('#draco-interesting-facts-close123').click(function() {
        return $factsBar.remove();
      });
      $('html:first').prepend($factsBar);
      $factsBar.find('#draco-interesting-facts-share').tooltip({
        title: "Share Fact",
        placement: 'right'
      });
      return $factsBar;
    },
    showFact: function() {
      var _this = this;
      if (this.hasFact()) {
        return $('#draco-interesting-facts123').show();
      } else {
        return chrome.extension.sendRequest({
          action: 'getFact'
        }, function(response) {
          if (is_site_disabled()) {
            return;
          }
          return _this.createNewFact(response.value);
        });
      }
    },
    hideFact: function() {
      return $('#draco-interesting-facts123').hide();
    },
    handleShareMessage: function(event) {
      var theIframe;
      DLog(event);
      theIframe = $('#draco-interesting-facts-share iframe').contentWindow;
      if (event.source !== theIframe) {
        return;
      }
      if (event.data === "Awesome Fact Shared") {
        DLog('shared success');
        $('#draco-interesting-facts-share').addClass("disabled").tooltip('disable');
        return noty({
          text: 'Current Fact Shared :)',
          layout: 'topLeft',
          type: 'success',
          theme: 'noty_theme_facebook'
        });
      } else if (event.data === "Awesome Fact Failed") {
        DLog('shared failed');
        return this.noty({
          text: 'Sharing Failed :(',
          layout: 'topLeft',
          type: 'error',
          theme: 'noty_theme_facebook'
        });
      }
    }
  };

  $(function() {
    if (is_site_disabled()) {
      return $('#draco-interesting-facts123').remove();
    }
  });

}).call(this);
