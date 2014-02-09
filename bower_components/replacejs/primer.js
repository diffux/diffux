releaseClicks = (function(document) {
  if (document.addEventListener) {
    var events = [];
    function handler(event) {
      var data = event.target.dataset;
      if (data && data.replace) {
        events.push(event);
        event.preventDefault();
      }
    }
    document.addEventListener('click', handler);
    return function() {
      document.removeEventListener('click', handler);
      return events;
    }
  }
})(document);
