require('cloud/app.js');

/* Initialize the Stripe and Mailgun and Shirts.io Cloud Modules */
var Stripe = require('stripe');
Stripe.initialize('sk_test_wZV5d5xnuHO6CPNqdfSxTRfR');

var Mailgun = require('mailgun');
Mailgun.initialize("sandbox7977b1ecfb534d6a8d560f5a09e7e67e.mailgun.org", "key-406c3a14ebaad20a11c58e815b170a45");

var shirtApiToken = "585708da69c2ae899f1461cd497f4a53";

// we charge 20 a shirt no matter what
var price = 20;


Parse.Cloud.define("createCustomer", function(request, response) {
  Parse.Promise.as().then(function() {
    return Stripe.Customers.create({
      email: request.params.email,
      description: request.params.email,
      metadata: {
      name: request.params.name,
        userId: request.params.userId, // e.g PFUser object ID
      }
      }).then(function(customer) {
      // And we're done!
      console.log(customer);
        response.success(customer);

      // Any promise that throws an error will propagate to this handler.
      // We use it to return the error from our Cloud Function using the 
      // message we individually crafted based on the failure above.
      }, function(error) {
        response.error(error);
    });
  });
});

Parse.Cloud.define("addCardToCustomer", function(request, response) {
  Parse.Promise.as().then(function() {
        return Parse.Cloud.httpRequest({
          method:"POST",
          //STRIPE_SECRET_KEY will be your stripe secret key obviously, this is different from the public key that you will use in your iOS/Android side.
          // STRIPE_API_BASE_URL = 'api.stripe.com/v1'
          url: "https://" + 'sk_test_wZV5d5xnuHO6CPNqdfSxTRfR' + ':@' + 'api.stripe.com/v1' + "/customers/" + request.params.customerId + "/cards",
          body: "card="+request.params["tokenId"]
      }).then(function() {
      // And we're done!
        response.success('Success');

      // Any promise that throws an error will propagate to this handler.
      // We use it to return the error from our Cloud Function using the 
      // message we individually crafted based on the failure above.
      }, function(error) {
        response.error(error);
    });
  });
});

Parse.Cloud.define("removeCardForCustomer", function(request, response) {
  Parse.Promise.as().then(function() {
        return Parse.Cloud.httpRequest({
          method:"DELETE",
          //STRIPE_SECRET_KEY will be your stripe secret key obviously, this is different from the public key that you will use in your iOS/Android side.
          // STRIPE_API_BASE_URL = 'api.stripe.com/v1'
          url: "https://" + 'sk_test_wZV5d5xnuHO6CPNqdfSxTRfR' + ':@' + 'api.stripe.com/v1' + "/customers/" + request.params.customerId + "/cards/" + request.params.cardId,
      }).then(function() {
      // And we're done!
        response.success('Success');

      // Any promise that throws an error will propagate to this handler.
      // We use it to return the error from our Cloud Function using the 
      // message we individually crafted based on the failure above.
      }, function(error) {
        response.error(error);
    });
  });
});

Parse.Cloud.define("listCardsForCustomer", function(request, response) {
  Parse.Promise.as().then(function() {
        return Parse.Cloud.httpRequest({
          method:"GET",
          //STRIPE_SECRET_KEY will be your stripe secret key obviously, this is different from the public key that you will use in your iOS/Android side.
          // STRIPE_API_BASE_URL = 'api.stripe.com/v1'
          url: "https://" + 'sk_test_wZV5d5xnuHO6CPNqdfSxTRfR' + ':@' + 'api.stripe.com/v1' + "/customers/" + request.params["customerId"] + "/cards"
      }).then(function(cards) {
      // And we're done!
        response.success(cards.data.data);

      // Any promise that throws an error will propagate to this handler.
      // We use it to return the error from our Cloud Function using the 
      // message we individually crafted based on the failure above.
      }, function(error) {
        response.error(error);
    });
  });
});

/*
 * Purchase an item from the Parse Store using the Stripe
 * Cloud Module.
 *
 * Expected input (in request.params):
 *   itemName       : String, can be "Mug, "Tshirt" or "Hoodie"
 *   size           : String, optional for items like the mug 
 *   cardToken      : String, the credit card token returned to the client from Stripe
 *   name           : String, the buyer's name
 *   email          : String, the buyer's email address
 *   address        : String, the buyer's street address
 *   city_state     : String, the buyer's city and state
 *   zip            : String, the buyer's zip code
 *
 * Also, please note that on success, "Success" will be returned. 
 */
Parse.Cloud.define("purchaseShirt", function(request, response) {
  // The Item and Order tables are completely locked down. We 
  // ensure only Cloud Code can get access by using the master key.
  Parse.Cloud.useMasterKey();

  // Top level variables used in the promise chain. Unlike callbacks,
  // each link in the chain of promise has a separate context.
  var order;

  // We start in the context of a promise to keep all the
  // asynchronous code consistent. This is not required.
  Parse.Promise.as().then(function() {
    order = new Parse.Object('Order');
    order.set('name', request.params.name);
    order.set('email', request.params.email);
    order.set('address1', request.params.address1);
    order.set('address2', request.params.address2);
    order.set('zipcode', request.params.zipcode);
    order.set('city', request.params.city);
    order.set('state', request.params.state);
    order.set('color', request.params.color);
    order.set('quantity', request.params.quantity);
    order.set('size', request.params.size);
    order.set('fulfilled', false);
    order.set('charged', false); // set to false until we actually charge the card
    order.set('shipped', false); // set to false until we actually charge the card

    // Create new order
    return order.save().then(null, function(error) {
      // This would be a good place to replenish the quantity we've removed.
      // We've ommited this step in this app.
      console.log('Creating order object failed. Error: ' + error);
      return Parse.Promise.error('An error has occurred. Your credit card was not charged.');
    });

  }).then(function(order) {
    // Now we can charge the credit card using Stripe and the credit card token.
    if(request.params.customer){
      return Stripe.Charges.create({
      amount: (price * request.params.quantity) * 100, // express dollars in cents 
      currency: 'usd',
      customer: request.params.customer,
    }).then(null, function(error) {
      console.log('Charging with stripe failed. Error: ' + error);
      return Parse.Promise.error('An error has occurred. Your credit card was not charged.');
    });
    }else{
      return Stripe.Charges.create({
      amount: (price * request.params.quantity) * 100, // express dollars in cents 
      currency: 'usd',
      card: request.params.token,
    }).then(null, function(error) {
      console.log('Charging with stripe failed. Error: ' + error);
      return Parse.Promise.error('An error has occurred. Your credit card was not charged.');
    });
    }
    

  }).then(function(purchase) {
    // Credit card charged! Now we save the ID of the purchase on our
    // order and mark it as 'charged'.
    order.set('stripePaymentId', purchase.id);
    order.set('charged', true);

    // Save updated order
    return order.save().then(null, function(error) {
      // This is the worst place to fail since the card was charged but the order's
      // 'charged' field was not set. Here we need the user to contact us and give us
      // details of their credit card (last 4 digits) and we can then find the payment
      // on Stripe's dashboard to confirm which order to rectify. 
      return Parse.Promise.error('A critical error has occurred with your order. Please ' + 
                                 'contact @ericlewis at your earliest convinience. ');
    });

  }).then(function() {
    // Handle shirts.io crap- if we get rejected from shirts.io then auto refund the card here & delete the order (or set it to fail?)

    var size = request.params.size;

    if (size == 'Small') {
      size = 'sml';
    }else if (size == 'Medium') {
      size = 'med';
    }else if (size == 'Large') {
      size = 'lrg';
    }else if (size == 'X-Large') {
      size = 'xlg';
    };

    return Parse.Cloud.httpRequest({
          method:"POST",
          //STRIPE_SECRET_KEY will be your stripe secret key obviously, this is different from the public key that you will use in your iOS/Android side.
          // STRIPE_API_BASE_URL = 'api.stripe.com/v1'
          url: 'https://api:' + shirtApiToken + '@api.scalablepress.com/v2/quote',
          body: 'type=dtg' +
              '&products[0][id]=canvas-v-neck-t-shirt' +
              "&products[0][color]=" + request.params.color + 
              "&products[0][quantity]=1" + //request.params.quantity +
              "&products[0][size]=" + size +
              "&address[name]="  + request.params.name +
              "&address[address1]=" + request.params.address1 +
              "&address[address2]=" + request.params.address2 +
              "&address[state]=" + request.params.state +
              "&address[city]=" + request.params.city +
              "&address[zip]=" + request.params.zipcode +
              "&sides[front]=1" +
              "&designId=544aa446dece094a0909ac4c",
      }).then(null, function(error) {
        return Parse.Promise.error('A critical error has occurred with your order. Please ' + 
                                 'contact @ericlewis at your earliest convinience. ');
    });

  }).then(function(shirtQuote) {

    return Parse.Cloud.httpRequest({
          method:"POST",
          //STRIPE_SECRET_KEY will be your stripe secret key obviously, this is different from the public key that you will use in your iOS/Android side.
          // STRIPE_API_BASE_URL = 'api.stripe.com/v1'
          url: 'https://api:' + shirtApiToken + '@api.scalablepress.com/v2/order',
          body: 'orderToken=' + shirtQuote.data.orderToken
      }).then(null, function(error) {
        console.log(error);
        return Parse.Promise.error('A critical error has occurred with your order. Please ' + 
                                 'contact @ericlewis at your earliest convinience. ');
    });

  }).then(function(shirtOrder) {
    // update acutal order object to have the id for the shirts.io thingie

    order.set('fulfilled', true);
    order.set('orderId', shirtOrder.data.orderId);
    order.set('quotePrice', shirtOrder.data.total);

    // Save updated order
    return order.save().then(null, function(error) {
      // This is the worst place to fail since the card was charged but the order's
      // 'charged' field was not set. Here we need the user to contact us and give us
      // details of their credit card (last 4 digits) and we can then find the payment
      // on Stripe's dashboard to confirm which order to rectify. 
      return Parse.Promise.error('A critical error has occurred with your order. Please ' + 
                                 'contact @ericlewis at your earliest convinience. ');
    });

  }).then(function(order) {
    // Credit card charged and order item updated properly!
    // We're done, so let's send an email to the user.

    // Generate the email body string.
    var body = "We've received and processed your order for the following: \n\n" +
               request.params.quantity + " " + request.params.color + " vneck(s)\n";

    if (request.params.size && request.params.size !== "N/A") {
      body += "Size: " + request.params.size + "\n";
    }

    body += "\nPrice: $" + price * request.params.quantity + ".00 \n" +
            "Shipping Address: \n" +
            request.params.name + "\n" +
            request.params.address1 + "\n" +
            request.params.address2 + "\n" +
            request.params.city + ", " + request.params.state + ", "
            " United States, " + request.params.zipcode + "\n" +
            "\nWe will send your item as soon as possible. " + 
            "Let us know if you have any questions!\n\n" +
            "Thank you,\n" +
            "The vneck Team";

    // Send the email.
    return Mailgun.sendEmail({
      to: request.params.email,
      from: 'ericlewis777@gmail.com',
      subject: 'Your order from vneck was successful!',
      text: body
    }).then(null, function(error) {
      console.log(error);
      return Parse.Promise.error('Your purchase was successful, but we were not able to ' +
                                 'send you an email. Contact us @ericlewis on twitter if ' +
                                 'you have any questions.');
    });

  }).then(function() {
    // And we're done!
    response.success('Success');

  // Any promise that throws an error will propagate to this handler.
  // We use it to return the error from our Cloud Function using the 
  // message we individually crafted based on the failure above.
  }, function(error) {
    response.error(error);
  });
});