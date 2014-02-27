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
        scrollToFocused();
        event.preventDefault();
        break;

      case 107: // k
        focusPreviousFocusable();
        scrollToFocused();
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

    function scrollToFocused() {
      var $focused = $('.keyboard-focused');
      if ($focused.length && !$focused.visible()) {
        $('html,body').stop(true, true).animate({
          scrollTop: $focused.offset().top - $(window).height() / 4
        }, 200);
      }
    }

    function openFocused() {
      var $focused = $('[data-keyboard-focusable]:visible.keyboard-focused');
      if ($focused.is('a')) {
        $focused[0].click();
      } else {
        var $link = $focused.find('a:visible:first');
        if ($link.length) {
          $link[0].click();
        }
      }
    }

    function openPreviousLevel() {
      var $link = $('.breadcrumb a:visible:last');
      if ($link.length) {
        $link[0].click();
      }
    }
  });
});
