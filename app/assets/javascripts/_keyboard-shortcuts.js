$(function() {
  $(document).on('keyup', function(event) {
    if ($(event.target).is(':input')) {
      return;
    }

    var $el = $('[data-keyboard-shortcut=' + event.which + ']'),
        href = $el.attr('href');
    if ($el.length && href) {
      Turbolinks.visit(href);
    }
  });
});
