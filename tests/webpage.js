var page = require('webpage').create();

page.open('https://www.google.co.jp/', function(status) {
  console.log('Status: ' + status);
  if (status == 'success') {
	page.render('google.png');
  }
  phantom.exit();
});
