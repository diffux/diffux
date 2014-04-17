var page = require('webpage').create(),
    opts = JSON.parse(require('system').args[1]);

page.viewportSize = opts.viewportSize;
if (opts.userAgent) {
  page.settings.userAgent = opts.userAgent;
} else {
  page.settings.userAgent = page.settings.userAgent + ' Diffux';
}

/**
 * Configure timeouts
 */
page.waitTimeouts = {
  initial: 1000,
  afterResourceDone: 300,
  fallback: 60000
};

/**
 * Saves a log string. The full log will be added to the console.log in the end,
 * so that consumers of this script can use that information.
 */
page.allLogs = [];
page.log = function(string) {
  page.allLogs.push(new Date().getTime() + ': ' + string);
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
    page.log('Done - page is ready.');
    clearTimeout(page.resourceWaitTimer);
    clearTimeout(page.fallbackWaitTimer);
    callback();
  };

  page.resourcesActive = [];

  page.onResourceRequested = function(request) {
    page.log('Ready: Request started - ' + request.url);
    page.log('Active requests - ' + page.resourcesActive);
    if (page.resourceWaitTimer) {
      page.log('Clearing timeout.');
      clearTimeout(page.resourceWaitTimer);
      page.resourceWaitTimer = null;
    }
    page.resourcesActive.push(request.id);
  };

  page.onResourceReceived = function(response) {
    page.log('Ready: Resource received - [' + response.id + '] '
        + response.url);
    page.log('Active requests - ' + page.resourcesActive);
    if (response.stage === 'end') {
      page.resourcesActive.splice(page.resourcesActive.indexOf(response.id), 1);

      if (page.resourcesActive.length === 0) {
        page.log('Potentially done, firing after short timeout.');
        page.resourceWaitTimer = setTimeout(fireCallback,
            page.waitTimeouts.afterResourceDone);
      }
    }
  };

  page.log('Starting default timeouts. ' + JSON.stringify(page.waitTimeouts));
  page.resourceWaitTimer = setTimeout(fireCallback, page.waitTimeouts.initial);
  page.fallbackWaitTimer = setTimeout(fireCallback, page.waitTimeouts.fallback);
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
  response.log    = page.allLogs.join('\n');
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
