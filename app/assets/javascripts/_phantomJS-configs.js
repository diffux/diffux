$(function() {
  // from
  // http://stackoverflow.com/questions/15739263/phantomjs-click-an-element
  if (window._phantom) {
    // Patch since PhantomJS does not implement click() on HTMLElement. In some
    // cases we need to execute the native click on an element. However, jQuery's
    // $.fn.click() does not dispatch to the native function on <a> elements, so we
    // can't use it in our implementations: $el[0].click() to correctly dispatch.
    if (!HTMLElement.prototype.click) {
      HTMLElement.prototype.click = function() {
        var ev = document.createEvent('MouseEvent');
        ev.initMouseEvent(
            'click',
            true, //bubble
            true, //cancelable
            window, null,
            0, 0, 0, 0, // coordinates
            false, false, false, false, // modifier keys
            0, // button=left
            null
        );
        this.dispatchEvent(ev);
      };
    }
  }
});

