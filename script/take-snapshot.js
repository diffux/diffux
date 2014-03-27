var page = require('webpage').create(),
    opts = JSON.parse(require('system').args[1]);

page.viewportSize = opts.viewportSize;
if (opts.userAgent) {
  page.settings.userAgent = opts.userAgent;
}

page.open(opts.address, function(status) {
  setTimeout(function() {
    // Try to prevent animations from running, to reduce variation in
    // snapshots.
    page.evaluate(function() {
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
      if (typeof $ !== 'undefined' && typeof $.fx !== 'undefined') {
        $.fx.off = true;
      }
    });

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
  }, 5000);
});
