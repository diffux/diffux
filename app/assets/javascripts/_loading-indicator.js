$(function() {
  var $indicator = $('<div class="loading-indicator bg-info">')
                     .html('Thinking&hellip;');

  // Listen to Turbolinks events
  $(document).on('page:fetch', function() {
    $indicator.appendTo('body');
  }).on('page:load', function() {
    $indicator.detach();
  });
});
