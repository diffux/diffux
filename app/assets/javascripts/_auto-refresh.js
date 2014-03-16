// This javascript file is responsible for refreshing elements on the page. It
// is tightly coupled to the `RefreshController`.
$(function() {
  var intervalInSeconds = 5;

  function prepareRefreshData() {
    var payload = {
      ifModifiedSince: window.lastKnownServerTime
    };
    $('[data-auto-refresh-type]').each(function(i, elem) {
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
      $.ajax({
        method: 'post',
        url:    '/refresh',
        data:   prepareRefreshData()
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
