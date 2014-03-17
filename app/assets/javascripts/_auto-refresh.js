// This javascript file is responsible for refreshing elements on the page. It
// is tightly coupled to the `RefreshController`.
$(function() {
  var intervalInSeconds = 5;

  function prepareRefreshData() {
    var $refreshers = $('[data-auto-refresh-type]'),
        payload     = { ifModifiedSince: window.lastKnownServerTime };
    if (!$refreshers.length) {
      return;
    }
    $refreshers.each(function(i, elem) {
      var $elem       = $(elem),
          typePlural  = $elem.data('auto-refresh-type') + 's',
          id          = $elem.data('auto-refresh-id');

      if (payload[typePlural]) {
        payload[typePlural].push(id)
      } else {
        payload[typePlural] = [id]
      }
    });
    return payload;
  }

  function refreshUI(refreshItems) {
    $(refreshItems).each(function(i, item) {
      $('[data-auto-refresh-id="' + item.id + '"]')
        .filter('[data-auto-refresh-type="' + item.type + '"]')
        .replaceWith(item.html);
    });
  }

  function autoRefresh() {
    setTimeout(function() {
      var data = prepareRefreshData();
      if (!data) {
        autoRefresh(); // Nothing to update, don't send request to server but
                       // keep polling.
        return;
      }
      $.ajax({
        method: 'post',
        url:    '/refresh',
        data:   data
      }).success(function(result) {
        window.lastKnownServerTime = result.serverTime;
        refreshUI(result.items);
      }).always(function() {
        autoRefresh(); // Trigger new poll
      });
    }, intervalInSeconds * 1000);
  }
  autoRefresh();
});
