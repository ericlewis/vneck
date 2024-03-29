//
//  AppDelegate.m
//  vnecks
//
//  Created by Eric Lewis on 10/20/14.
//  Copyright (c) 2014 Eric Lewis. All rights reserved.
//

#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>
#import "PFFacebookUtils.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Stripe.h"
#import "Appirater.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0], NSFontAttributeName, nil]];
    
    [[UIApplication sharedApplication] keyWindow].tintColor = [UIColor whiteColor];
    
    // setup stripe
    [Stripe setDefaultPublishableKey:@"pk_live_be5iKwsPB6mQRxKrNRK81Iyp"];
    
    // parse stuff
    [Parse setApplicationId:@"q35h3MSpJWR3IyvPqEXhVT2269fid5OzWczwtkmc"
                  clientKey:@"QyHU7DdJfw0K88q3ghHJ7FeDlWljFV3rocqUc6jt"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // rating stuff
    [Appirater setAppId:@"931893685"];
    [Appirater setUsesUntilPrompt:3];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:1];
    
#if DEBUG
    [Appirater setDebug:YES];
#else
    [Appirater setDebug:NO];
#endif
    
    [Appirater appLaunched:YES];
    
    [PFFacebookUtils initializeFacebook];
    
    [Crashlytics startWithAPIKey:@"aa3ebef69236c7e1ec3eb569123ce003350b80c9"];

    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    [FBAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[PFFacebookUtils session] close];
}

@end
