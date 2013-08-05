var page = require('webpage').create();
var args = require('system').args;
var address = args[1];
var outfile = args[2];

console.log('Generating snapshot for ' + address + ' into ' + outfile);

page.open(address, function () {
    page.render(outfile);
    phantom.exit();
});
