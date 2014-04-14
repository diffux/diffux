var page = require('webpage').create(),
    opts = JSON.parse(require('system').args[1]);

page.viewportSize = opts.viewportSize;
if (opts.userAgent) {
  page.settings.userAgent = opts.userAgent;
} else {
  page.settings.userAgent = page.settings.userAgent + ' Diffux';
}

/**
 * Logs a console.log message if debug mode is on (turn it on by passing in
 * `debug: true` as part of the json arg).
 */
page.debugLog = function(string) {
  if (!opts.debug) {
    return;
  }
  console.log(string);
};

/**
 * By preventing animations from happening when we are taking the snapshots, we
 * avoid timing issues that cause unwanted differences.
 */
page.preventAnimations = function() {
  // CSS Transitions
  var css   = document.createElement('style');
  css.type  = 'text/css';
  document.head.appendChild(css);
  var sheet = css.sheet;
  sheet.addRule('*', '-webkit-transition: none !important;');
  sheet.addRule('*', 'transition: none !important;');
  sheet.addRule('*', '-webkit-animation-duration: 0 !important;');
  sheet.addRule('*', 'animation-duration: 0 !important;');

  // jQuery
  if (window.jQuery) {
    jQuery.fx.off = true;
    jQuery('*').stop(true, true);
  }

  // Prevent things like blinking cursors by un-focusing any focused
  // elements
  document.activeElement.blur();
};


/**
 * Waits until the page is ready and then fires a callback.
 *
 * This method will keep track of all resources requested (css, javascript, ajax
 * requests, etc). As soon as we have no outstanding requests active, we start a
 * short timer which fires the callback. If a new resource is requested in that
 * short timeframe, we cancel the timer and wait for the new resource.
 *
 * In case something goes wrong, there's a 10 second fallback timer running in
 * the background.
 */
page.waitUntilReady = function(callback) {
  var fireCallback = function() {
    page.debugLog('Done - page is ready.');
    clearTimeout(page.resourceWaitTimer);
    clearTimeout(page.fallbackWaitTimer);
    callback();
  };

  page.resourcesActive = [];

  page.onResourceRequested = function(request) {
    page.debugLog('Ready: Request started - ' + request.url);
    page.debugLog('Active requests - ' + page.resourcesActive);
    if (page.resourceWaitTimer) {
      page.debugLog('Clearing timeout.');
      clearTimeout(page.resourceWaitTimer);
      page.resourceWaitTimer = null;
    }
    page.resourcesActive.push(request.id);
  };

  page.onResourceReceived = function(response) {
    page.debugLog('Ready: Resource received - [' + response.id + '] '
        + response.url);
    page.debugLog('Active requests - ' + page.resourcesActive);
    if (response.stage === 'end') {
      page.resourcesActive.splice(page.resourcesActive.indexOf(response.id), 1);

      if (page.resourcesActive.length === 0) {
        page.debugLog('Potentially done, firing after short timeout.');
        page.resourceWaitTimer = setTimeout(fireCallback, 300);
      }
    }
  };

  page.debugLog('Starting default timeouts.');
  page.resourceWaitTimer = setTimeout(fireCallback, 1000);
  page.fallbackWaitTimer = setTimeout(fireCallback, 20000);
};

/**
 * Main place for taking the screenshot. Will exit the script when done.
 */
page.takeDiffuxSnapshot = function() {
  // Try to prevent animations from running, to reduce variation in
  // snapshots.
  page.evaluate(page.preventAnimations);

  // Save a PNG of the rendered page
  page.render(opts.outfile);

  // Capture metadata
  var response = page.evaluate(function() {
    return { title: document.title };
  });

  response.opts   = opts;
  response.status = status;

  // The phantomjs gem can read what is written to STDOUT which includes
  // console.log, so we can use that to pass information from phantomjs back
  // to the app.
  console.log(JSON.stringify(response));

  phantom.exit();
};

page.open(opts.address, function(status) {
  page.waitUntilReady(page.takeDiffuxSnapshot);
});
