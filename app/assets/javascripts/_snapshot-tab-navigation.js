$(document).on('click', '.snapshot-diff-image .nav-tabs a', function(e) {
  e.preventDefault();
  $tab = $(e.target);
  $tab.closest('li').addClass('active')
    .siblings().removeClass('active');
  $('.snapshot-diff-sprite img').css('margin-left',
    $tab.data('diff-offset'));
})
