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
});
