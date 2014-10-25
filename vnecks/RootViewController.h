//
//  RootViewController.h
//  vnecks
//
//  Created by Eric Lewis on 10/20/14.
//  Copyright (c) 2014 Eric Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet UIButton *orderButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *accountButton;
@property (strong, nonatomic) NSString *shirtColor;
@property (strong, nonatomic) NSString *numberOfShirtsString;
@property (nonatomic) BOOL applePayAllowed;
@property (nonatomic) BOOL usingApplePay;

@end

