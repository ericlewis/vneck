//
//  OnboardingViewController.m
//  vnecks
//
//  Created by Eric Lewis on 10/20/14.
//  Copyright (c) 2014 Eric Lewis. All rights reserved.
//

#import "OnboardingViewController.h"
#import <Parse/Parse.h>
#import "PFFacebookUtils.h"
#import <SpinKit/RTSpinKitView.h>
#import "MBProgressHUD.h"

@interface OnboardingViewController ()

@end

@implementation OnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)connectWithFacebookButton:(id)sender {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[@"email"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];

            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            
            // prompt for size if the user doesn't already have one-
            
            // finish login afterwards
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                [[PFUser currentUser] setObject:result[@"name"] forKey:@"name"];
                [[PFUser currentUser] setObject:result[@"email"] forKey:@"email"];

                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (user.isNew) {
                        NSLog(@"User with facebook signed up and logged in!");
                        NSDictionary *chargeParams = @{
                                                       @"userId": [[PFUser currentUser] objectId],
                                                       @"email": [[PFUser currentUser] email],
                                                       @"name": [PFUser currentUser][@"name"],
                                                       };
                        // This passes the token off to our payment backend, which will then actually complete charging the card using your account's
                        [PFCloud callFunctionInBackground:@"createCustomer" withParameters:chargeParams block:^(id object, NSError *error) {
                            if (error) {
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                NSLog(@"%@", error);
                                return;
                            }
                            else {
                                [[PFUser currentUser] setObject:object[@"id"] forKey:@"stripeCustomerId"];
                                // We're done!
                                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    if (error) {
                                        NSLog(@"%@", error);
                                        return;
                                    }
                                }];
                            }
                        }];

                    } else {
                        NSLog(@"User with facebook logged in!");
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    }
                    
                    [self.navigationController popToRootViewControllerAnimated:NO];
                }];
            }];
        }
    }];
    
    RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleChasingDots color:[UIColor whiteColor]];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.square = YES;
    hud.dimBackground = YES;
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = spinner;
    
    [spinner startAnimating];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
