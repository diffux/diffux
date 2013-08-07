$(document).on('submit', 'form', function(event) {
  $(event.target).find('.spin-on-submit')
    .prop('disabled', true)
    .text('This might take a while...')
    .spin('small');
});
