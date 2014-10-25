
// These two lines are required to initialize Express in Cloud Code.
var express = require('express');
var app = express();

// Global app configuration section
app.use(express.bodyParser());    // Middleware for reading request body

// This is an example of hooking up a request handler with a specific request
// path and HTTP verb using the Express routing API.
app.post('/update_order',
         express.basicAuth('order', 'crackSmokingWhoreBangingAssLover23900011'),
         function(req, res) {
  Parse.Cloud.useMasterKey();

  var Order = new Parse.Query("Order");
    Order.equalTo("orderId", req.body.orderId);
    Order.find({
        success: function(results) {
            var obj = results[0];
                obj.set("shipped", true);
                return obj.save();
        }
  }).then(function() {
    res.send('Success');
  }, function(error) {
	console.log(error);
    res.status(500);
    res.send('Error');
  });
});

app.listen();
