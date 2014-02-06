var page = require('webpage').create(),
    opts = JSON.parse(require('system').args[1]);

page.viewportSize = opts.viewportSize;
page.open(opts.address, function(status) {
  setTimeout(function() {
    page.render(opts.outfile);

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
