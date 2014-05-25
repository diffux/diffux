(function() {
  var navSelector = '.snapshot-diff-image .nav';

  $(document).on('click', navSelector + ' a', function(e) {
    e.preventDefault();
    $tab = $(e.target);
    $tab.closest('li').addClass('active')
      .siblings().removeClass('active');
    $('.snapshot-diff-sprite img').css('margin-left',
      $tab.data('diff-offset'));
  });

  function makeNavAffix() {
    $nav = $(navSelector);
    if (!$nav.length) {
      return;
    }
    $nav.affix({
      offset: { top: $nav.offset().top }
    });
  }

  $(document).on('page:load', makeNavAffix);
  $(makeNavAffix);
})();
