var page = require('webpage').create();
var opts = JSON.parse(require('system').args[1]);

console.log('Generating snapshot for ' + opts.address + ' into ' + opts.outfile);
page.open(opts.address, function () {
    page.render(opts.outfile);
    phantom.exit();
});
