$(function() {
  $(document).on('keypress', function(event) {
    if ($(event.target).is(':input')) {
      return;
    }

    switch (event.which) {
      case 91: // [
        focusPreviousFocusable();
        openFocused();
        event.preventDefault();
        break;

      case 93: // ]
        focusNextFocusable();
        openFocused();
        event.preventDefault();
        break

      case 106: // j
        focusNextFocusable();
        event.preventDefault();
        break;

      case 107: // k
        focusPreviousFocusable();
        event.preventDefault();
        break;

      case 13:  // Enter
      case 111: // o
        openFocused();
        event.preventDefault();
        break;

      case 117: // u
        openPreviousLevel();
        event.preventDefault();
        break;
    }

    function focusNextFocusable() {
      if (!moveFocus(1)) {
        $('[data-keyboard-focusable]:first:visible')
          .addClass('keyboard-focused');
      }
    }

    function focusPreviousFocusable() {
      moveFocus(-1);
    }

    // @param movement [Integer] -1 to move backwards 1, or 1 to move forward 1
    // @return [Boolean] true if movement was successful, false otherwise
    function moveFocus(movement) {
      var $focusable = $('[data-keyboard-focusable]:visible'),
          $focused   = $focusable.filter('.keyboard-focused');
      if ($focused.length) {
        var moveTo = $focusable.index($focused) + movement;
        if (moveTo >= 0 && moveTo < $focusable.length) {
          $focused.removeClass('keyboard-focused');
          $focusable.eq(moveTo).addClass('keyboard-focused');
        }
        return true;
      }
      return false;
    }

    function openFocused() {
      var $focused = $('[data-keyboard-focusable]:visible.keyboard-focused');
      if ($focused.is('a')) {
        $focused[0].click();
      } else {
        $focused.find('a:visible:first')[0].click();
      }
    }

    function openPreviousLevel() {
      $('.breadcrumb a:visible:last')[0].click();
    }
  });
});
