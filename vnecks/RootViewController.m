//
//  RootViewController.m
//  vnecks
//
//  Created by Eric Lewis on 10/20/14.
//  Copyright (c) 2014 Eric Lewis. All rights reserved.
//

#import "Stripe.h"
#import "Stripe+ApplePay.h"
#import <Parse/Parse.h>
#import <AddressBook/AddressBook.h>
#import "UIActionSheet+Blocks.h"
#import <SpinKit/RTSpinKitView.h>
#import "MBProgressHUD.h"
#import "Chuzzle.h"
#import "ActionSheetStringPicker.h"
#import "SCLAlertView.h"

#import "RootViewController.h"
#import "ModelController.h"
#import "ItemViewController.h"


#if DEBUG
#import "STPTestPaymentAuthorizationViewController.h"
#import "PKPayment+STPTestKeys.h"
#endif

#define MERCHANT_ID @"merchant.com.eel.vneck"

@interface RootViewController ()<PKPaymentAuthorizationViewControllerDelegate>
@property (readonly, strong, nonatomic) ModelController *modelController;
@property (strong, nonatomic) NSArray *pickerData;
@property (strong, nonatomic) NSArray *creditCards;
@end

@implementation RootViewController

@synthesize modelController = _modelController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize Data
    _pickerData = @[@"Small", @"Medium", @"Large", @"X-Large"];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];

    PFUser *currentUser = [PFUser currentUser];
    
    // user is not logged in
    if (!currentUser) {
        UIStoryboard *storyBoard = self.storyboard;
        UIViewController *targetViewController = [storyBoard instantiateViewControllerWithIdentifier:@"OnboardingView"];
        UINavigationController *navController = self.navigationController;
        
        // if the user isn't logged in the prompt them to login
        if (navController) {
            self.view.alpha = 0;
            [navController pushViewController:targetViewController animated:NO];
        }
    }
    
    // user is logged in, check if they can use apple pay
    else{
        [self setApplePayEnabled];
    }

    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;

    ItemViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    self.pageViewController.dataSource = self.modelController;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    self.pageViewController.view.frame = pageViewRect;

    [self.pageViewController didMoveToParentViewController:self];

    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    
    [self.view bringSubviewToFront:self.accountButton];
    [self.view bringSubviewToFront:self.shareButton];
    [self.view bringSubviewToFront:self.orderButton];
    
    UIImage * __weak image = [self.shareButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    [self.shareButton setImage:image forState:UIControlStateNormal];
    
    image = [self.accountButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.accountButton setImage:image forState:UIControlStateNormal];    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    
    // animate the buttons in here- only if first launch
    if (self.view.alpha == 0) {
        [UIView animateWithDuration:0.4 animations:^{
            self.view.alpha = 1;
        }];
    }
    
    // setup order button according to user state-
    
    // if logged in and hasn't added shipping show shipping
    
    // if logged in and has no cards period, show add card
    
    // else show order
    PFUser *currentUser = [PFUser currentUser];
    
    [self setApplePayEnabled];
    
    if (currentUser) {
        NSString *size = currentUser[@"size"];
        // no size, prompt for it
        if (!size.chuzzle) {
            [self.orderButton setTitle:@"CHOOSE SIZE" forState:UIControlStateNormal];
        }
        
        // not using apple pay so ask for address to ship to
        // should be: else if (!self.applePayAllowed) {
        else if (!self.applePayAllowed) {
            NSString *address = currentUser[@"address1"];
            
            //
            if (!address.chuzzle) {
                [self.orderButton setTitle:@"ADD ADDRESS" forState:UIControlStateNormal];
            }else{
                [self.orderButton setTitle:@"LOADING..." forState:UIControlStateNormal];
                
                
                [PFCloud callFunctionInBackground:@"listCardsForCustomer" withParameters:@{@"customerId" : [PFUser currentUser][@"stripeCustomerId"]} block:^(id object, NSError *error) {
                    self.creditCards = object;
                    
                    if (self.creditCards.count == 0) {
                        [self.orderButton setTitle:@"ADD CREDIT CARD" forState:UIControlStateNormal];
                    }else{
                        [self.orderButton setTitle:@"ORDER" forState:UIControlStateNormal];
                    }
                    
                }];
            }
        }else{
            [self.orderButton setTitle:@"ORDER" forState:UIControlStateNormal];
        }
    }

}

- (void)setApplePayEnabled{
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]){
        NSOperatingSystemVersion ios8_1_0 = (NSOperatingSystemVersion){8, 1, 0};
        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios8_1_0]) {
            PFUser *currentUser = [PFUser currentUser];
            
            PKPaymentRequest *paymentRequest = [Stripe
                                                paymentRequestWithMerchantIdentifier:MERCHANT_ID
                                                amount:0
                                                currency:@"USD"
                                                description:nil];
            if (currentUser && [Stripe canSubmitPaymentRequest:paymentRequest]) {
                self.applePayAllowed = YES;
            }else{
                self.applePayAllowed = NO;
            }
        }else{
            self.applePayAllowed = NO;
        }
    } else {
        // we're on iOS 7 or below
        self.applePayAllowed = NO;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)orderButton:(id)sender {
    NSArray *numberOfShirts = @[@"5", @"4", @"3", @"2", @"1"];
    self.numberOfShirtsString = @"0";

    if ([self.orderButton.titleLabel.text isEqualToString:@"ORDER"]) {
        [UIActionSheet showInView:self.view
                        withTitle:@"Select number of shirts to order."
                cancelButtonTitle:@"Cancel"
           destructiveButtonTitle:nil
                otherButtonTitles:numberOfShirts
                         tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                             if (buttonIndex != [actionSheet cancelButtonIndex]) {
                                 
                                 // the number of shirts to buy
                                 self.numberOfShirtsString = numberOfShirts[buttonIndex];
                                 
                                 PKPaymentRequest *paymentRequest = [Stripe
                                                                     paymentRequestWithMerchantIdentifier:MERCHANT_ID
                                                                     amount:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%li", [self.numberOfShirtsString integerValue] * 20]]
                                                                     currency:@"USD"
                                                                     description:[NSString stringWithFormat:@"%@ %@ vneck shirt(s)", self.numberOfShirtsString, self.shirtColor]];
                                 
                                 [paymentRequest setRequiredShippingAddressFields:PKAddressFieldPostalAddress];
                                 
                                 // Apple pay
                                 if (self.applePayAllowed) {
#if DEBUG
                                     STPTestPaymentAuthorizationViewController *auth = [[STPTestPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
#else
                                     PKPaymentAuthorizationViewController *auth = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
#endif
                                     auth.delegate = self;
                                     [self presentViewController:auth animated:YES completion:nil];
                                     
                                 }
                                 
                                 // Fallback
                                 else{
                                     
                                     NSMutableArray *cardNames = [[NSMutableArray alloc] init];
                                     
                                     for (id object in self.creditCards) {
                                         [cardNames addObject:[NSString stringWithFormat:@"%@ %@", object[@"brand"], object[@"last4"]]];
                                     }
                                     
                                     // fetch CCs & show payment methods
                                     [UIActionSheet showInView:self.view
                                                     withTitle:@"Choose payment method."
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:cardNames
                                                      tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                                          if ([actionSheet cancelButtonIndex] != buttonIndex) {
                                                              [UIActionSheet showInView:self.view withTitle:@"Confirm Order" cancelButtonTitle:[NSString stringWithFormat:@"Pay $%li.00", [self.numberOfShirtsString integerValue] * 20] destructiveButtonTitle:@"Cancel" otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                                                  if (buttonIndex == [actionSheet cancelButtonIndex]) {
                                                                      // get token for ID we added from Add Credit Card
                                                                      [self createBackendChargeWithToken:self.creditCards[buttonIndex-1][@"id"] completion:^(PKPaymentAuthorizationStatus test) {
                                                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                                      }];
                                                                      
                                                                      RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleChasingDots color:[UIColor whiteColor]];
                                                                      
                                                                      MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                                      hud.square = YES;
                                                                      hud.dimBackground = YES;
                                                                      hud.mode = MBProgressHUDModeCustomView;
                                                                      hud.customView = spinner;
                                                                      
                                                                      [spinner startAnimating];
                                                                  }
                                                              }];
                                                          }
                                                          
                                                      }];
                                 }
                             }
                             
                         }];
    }else if ([self.orderButton.titleLabel.text isEqualToString:@"CHOOSE SIZE"]){
        [ActionSheetStringPicker showPickerWithTitle:@"Select your size"
                                                rows:_pickerData
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               [[PFUser currentUser] setObject:selectedValue forKey:@"size"];
                                               [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                   
                                                   [self viewWillAppear:NO];
                                               }];
                                               
                                               
                                               RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleChasingDots color:[UIColor whiteColor]];
                                               
                                               MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                               hud.square = YES;
                                               hud.mode = MBProgressHUDModeCustomView;
                                               hud.customView = spinner;
                                               
                                               [spinner startAnimating];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"Block Picker Canceled");
                                         }
                                              origin:self.view];
    }else if ([self.orderButton.titleLabel.text isEqualToString:@"ADD ADDRESS"]){
        UIStoryboard *storyBoard = self.storyboard;
        UIViewController *targetViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EditShippingView"];
        UINavigationController *navController = self.navigationController;
        
        if (navController) {
            [navController pushViewController:targetViewController animated:YES];
        }
    }else if ([self.orderButton.titleLabel.text isEqualToString:@"ADD CREDIT CARD"]){
        UIStoryboard *storyBoard = self.storyboard;
        UIViewController *targetViewController = [storyBoard instantiateViewControllerWithIdentifier:@"AddCreditCardView"];
        UINavigationController *navController = self.navigationController;
        
        if (navController) {
            [navController pushViewController:targetViewController animated:YES];
        }
    }
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}

- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    void(^tokenBlock)(STPToken *token, NSError *error) = ^void(STPToken *token, NSError *error) {
        if (error) {
            completion(PKPaymentAuthorizationStatusFailure);
            return;
        }
        
        self.usingApplePay = YES;
        
        // set the users shipping address first based on the payment.
        ABMultiValueRef addresses = ABRecordCopyValue([payment shippingAddress], kABPersonAddressProperty);
        
        for (CFIndex index = 0; index < ABMultiValueGetCount(addresses); index++)
        {
            CFDictionaryRef properties = ABMultiValueCopyValueAtIndex(addresses, index);
            NSString *street = [(__bridge NSString *)(CFDictionaryGetValue(properties, kABPersonAddressStreetKey)) copy];
            NSString *state = [(__bridge NSString *)(CFDictionaryGetValue(properties, kABPersonAddressStateKey)) copy];
            NSString *city = [(__bridge NSString *)(CFDictionaryGetValue(properties, kABPersonAddressCityKey)) copy];
            NSString *zip = [(__bridge NSString *)(CFDictionaryGetValue(properties, kABPersonAddressZIPKey)) copy];
            
            PFUser *currentUser = [PFUser currentUser];
            
            [currentUser setObject:street forKey:@"address1"];
            [currentUser setObject:@"" forKey:@"address2"];
            [currentUser setObject:city forKey:@"city"];
            [currentUser setObject:state forKey:@"state"];
            [currentUser setObject:zip forKey:@"zipcode"];
            
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self createBackendChargeWithToken:token completion:completion];
            }];
        }
        
        RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleChasingDots color:[UIColor whiteColor]];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.square = YES;
        hud.dimBackground = YES;
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = spinner;
        
        [spinner startAnimating];
    };
#if DEBUG
    if (payment.stp_testCardNumber) {
        STPCard *card = [STPCard new];
        card.number = payment.stp_testCardNumber;
        card.expMonth = 12;
        card.expYear = 2020;
        card.cvc = @"123";
        [Stripe createTokenWithCard:card completion:tokenBlock];
        return;
    }
#endif
    [Stripe createTokenWithPayment:payment
                    operationQueue:[NSOperationQueue mainQueue]
                        completion:tokenBlock];
}

- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    PFUser *currentUser = [PFUser currentUser];
    
    NSString *tokenId = @"";
    
    if ([token isKindOfClass:[STPToken class]]) {
        tokenId = token.tokenId;
    }else{
        tokenId = (NSString*)token;
    }
    
    NSMutableDictionary *chargeParams = @{
                                   @"token": tokenId,
                                   @"currency": @"usd",
                                   @"objectId" : [[PFUser currentUser] objectId],
                                   @"color" : self.shirtColor,
                                   @"size"  : currentUser[@"size"],
                                   @"quantity" : self.numberOfShirtsString,
                                   @"name" : currentUser[@"name"],
                                   @"email": currentUser.email,
                                   @"address1" : currentUser[@"address1"],
                                   @"address2" : currentUser[@"address2"],
                                   @"zipcode" : currentUser[@"zipcode"],
                                   @"city" : currentUser[@"city"],
                                   @"state" : currentUser[@"state"],
                                   @"address1" : currentUser[@"address1"],
                                   @"useApplePay" : self.usingApplePay ? @"true" : @"false"
                                   };
    
    if (self.applePayAllowed == NO) {
        [chargeParams addObject:[PFUser currentUser][@"stripeCustomerId"] forkey:@"customer"];
        [chargeParams addObject:tokenId forkey:@"token"];
    }
    // This passes the token off to our payment backend, which will then actually complete charging the card using your account's
    [PFCloud callFunctionInBackground:@"purchaseShirt" withParameters:chargeParams block:^(id object, NSError *error) {
        if (error) {
            completion(PKPaymentAuthorizationStatusFailure);
            
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            alert.hideAnimationType = SlideOutToBottom;
            [alert showError:self title:@"Payment Failed" subTitle:error.userInfo[@"error"] closeButtonTitle:@"OK" duration:0.0f]; // Error
        }
        else {
            // We're done!
            completion(PKPaymentAuthorizationStatusSuccess);
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            alert.hideAnimationType = SlideOutToBottom;
            [alert showSuccess:self title:@"Thank you." subTitle:@"Your order has been accepted." closeButtonTitle:@"Done" duration:0.0f];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareButton:(id)sender {
    NSString *textToShare = @"Never make shirt decisions again!";
    NSURL *myWebsite = [NSURL URLWithString:@"http://appstore.com/weedly"];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (ModelController *)modelController {
    // Return the model controller object, creating it if necessary.
    // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[ModelController alloc] init];
    }
    return _modelController;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
