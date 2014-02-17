$(function() {

  $(document).on('page:change', function() {
    var $activeSnapshot = $('.snapshot-card-active');
    if (!$activeSnapshot.length) {
      return;
    }
    var $panelBody = $activeSnapshot.closest('.panel-body'),
        scrollLeft = $activeSnapshot.offset().left - $panelBody.width() / 3;
    $panelBody.scrollLeft(scrollLeft);
  });

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
      Turbolinks.visit($goTo.attr('href'));
    }
  });
});
