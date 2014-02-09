// Allow links to replace part of the page, rather than the entire thing.
//
//   <div class="container">
//     <a href="/foo" data-replace=".container">Foo</a>
//   </div>
//
// When you click the link "Foo", it will:
// - Find an ancestor element matching the selector ".container".
// - Perform a GET request to /foo.
// - If the request is successful, replace the ancestor with the response body.
//
// It also works for forms:
//
//   <div class="container">
//     <form action="/bar" method="POST" data-replace=".container">
//       <input type="submit">
//     </form>
//   </div>
//
// Notes:
// - It is possible to replace the same element that was clicked/submitted. A
//   convenient selector for doing so is "*".
// - If a link has the attribute "data-pushstate" and the browser supports it,
//   the address bar will be updated on success using history.pushState.
// - The container will have the class ".replace-active" while a replace
//   operation is in progress. This can be useful for styling purposes.
// - Clicks inside a container with a replace operation in progress are ignored.
//   This obviates the need to prevent double submissions of forms.

(function($, undefined) {
  // Apply callback to every descendent matching selector that exists at page
  // load or that is added later. This frees you as the developer from having to
  // find every place in the codebase where a given widget might be added to the
  // page and attaching its initialization logic there.
  //
  // Example:
  //   $(document).initializeEach('[data-background-url]', function() {
  //     $(this).waypoint(function() {
  //       $(this).css('backgroundUrl', $(this).data('backgroundUrl'));
  //     }, { offset: '100%', triggerOnce: true });
  //   });
  //
  // It is also possible to nest these calls.
  //
  //   $(document).initializeEach('.discussion-board', function() {
  //     $(this).initializeEach('.discussion-post', function() {
  //       // ...
  //     });
  //   });
  //
  $.fn.initializeEach = function(selector, callback) {
    this
      .on('replace:done', function(event) {
        $(event.target).find(selector).addBack(selector).each(callback);
      })
      .find(selector).each(callback);
  };

  // Replace an element with the result of an AJAX request.
  function ajaxReplace($elem, url, options) {
    if ($elem.closest('.replace-active').length) {
      return;
    }
    options = options || {};
    var $container = $elem.closest(options.selector || '*');
    $container.addClass('replace-active').trigger('replace:start');

    $.ajax(url, { type: options.method, data: options.data })
      .always(function() {
        $container.removeClass('replace-active');
      })
      .done(function(data) {
        if (options.success) {
          options.success($container, data);
        }
        $(data).replaceAll($container).trigger('replace:done');
      })
      .fail(function() {
        $container.trigger('replace:fail');
      });
  }

  $(window).on('popstate', function(event) {
    var state = event.originalEvent.state;
    if (state && state.selector) {
      $(state.data).replaceAll(state.selector)
                   .trigger('replace:done');
    }
  });

  $(document).on('click', 'a[data-replace]', function(event) {
    var $link = $(this);

    if ($link.data('pushstate')) {
      if (!window.history || !history.pushState) {
        // If a link would like to use pushState but that is not supported by
        // the browser, we'll let it do a full page load. Affects IE 8/9 users.
        return;
      }
      if (event.shiftKey || event.metaKey) {
        // User is trying to open link in a new tab or window. Allow default.
        return;
      }
    }

    event.preventDefault();

    ajaxReplace($link, $link.attr('href'), {
      selector: $link.data('replace'),
      success: function($container, data) {
        if ($link.data('pushstate')) {
          history.replaceState({
            selector: $link.data('replace'),
            data: $container[0].outerHTML
          }, null);
          history.pushState({
            selector: $link.data('replace'),
            data: data
          }, null, $link.attr('href'));
        }
      }
    });
  });

  $(document).on('submit', 'form[data-replace]', function(event) {
    event.preventDefault();
    var $form = $(this);

    ajaxReplace($form, $form.attr('action'), {
      selector: $form.data('replace'),
      method: $form.attr('method'),
      data: $form.serialize()
    });
  });

  // When you submit a form using the built-in click handler for buttons, the
  // clicked button's name/value will be added to the query string. This can be
  // useful for knowing which button was clicked in a form with several of
  // them. When we submit the form programatically, the clicked button is no
  // longer active and we have no way of knowing which one it was. This click
  // handler emulates the built-in functionality.
  $(document).on('click', 'form[data-replace] button', function(event) {
    var $button = $(this);
    $('<input type="hidden">')
      .prop('name', $button.prop('name'))
      .val($button.val())
      .appendTo($button.closest('form'));
  });

  if (window.releaseClicks) {
    $.each(releaseClicks(), function(_, event) {
      $(event.target).trigger(event.type);
    });
  }

  // Allows sections of the page to be lazily loaded just before they come into
  // view. Implementation is simple: just add a 'lazy-url' data attribute like so
  //
  //   <div data-lazy-url="http://causes.com/expensive/content"></div>
  //
  // The rest will be handled by this code, in conjunction with the jQuery
  // waypoints plug-in (http://imakewebthings.com/jquery-waypoints/); if the
  // plug-in is not available, we degrade gracefully and revert to eager
  // loading.
  //
  // To have the lazy url trigger based on horizontal offset, set the
  // 'lazy-horizontal' data attribute to 'true'.
  //
  // To set a custom context set the 'lazy-context' data attribute to a CSS
  // selector. A custom context is an element which acts as the relative point
  // from which the offset is considered. This defaults to the window.
  //
  // To specify a custom waypoint offset set the 'lazy-offset' data attribute to
  // either a specific value with units or a percentage.
  //
  // Note that we support adding yet-more lazy content onto the page after page
  // initialization, but only when using Replace.js.
  $(document).initializeEach('[data-lazy-url]', function() {
    var $this = $(this);
    if (typeof $.fn.waypoint === 'function') {
      var waypointOptions = {
        offset: '120%',
        triggerOnce: true,
        handler: function() {
          ajaxReplace($this, $this.data('lazy-url'));
        }
      };

      if ($this.data('lazyHorizontal')) {
        waypointOptions.horizontal = true;
        waypointOptions.direction = 'right';
      }

      var offset = $this.data('lazyOffset');
      if (offset) {
        waypointOptions.offset = offset;
      }

      var dataContext = $this.data('lazyContext');
      if (dataContext) {
        waypointOptions.context = dataContext;
      }

      $this.waypoint(waypointOptions);
    } else {
      ajaxReplace($this, $this.data('lazy-url'));
    }
  });
})(jQuery);
