$(function() {
  $(document).on('keyup', function(event) {
    var $panel          = $('.snapshot-review-panel'),
        $activeSnapshot = $panel.find('.snapshot-card-active'),
        $goTo;
    if (event.which == 37) { // Left arrow
      $goTo = $activeSnapshot.prev();
    } else if (event.which == 39) { // Right arrow
      $goTo = $activeSnapshot.next();
    } else {
      return;
    }

    if ($goTo.length) {
      Turbolinks.visit($goTo.find('a').first().attr('href'));
    }
  });
});
