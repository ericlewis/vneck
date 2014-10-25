//
//  ItemViewController.m
//  vnecks
//
//  Created by Eric Lewis on 10/20/14.
//  Copyright (c) 2014 Eric Lewis. All rights reserved.
//

#import "ItemViewController.h"
#import "RootViewController.h"

@interface ItemViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *shirtImageView;
@end

@implementation ItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.view.backgroundColor = [UIColor clearColor];
    
    if ([self.dataObject isEqualToString:@"1"]) {
        self.shirtImageView.image = [UIImage imageNamed:@"white-shirt"];
    }else{
        self.shirtImageView.image = [UIImage imageNamed:@"black-shirt"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    RootViewController *rootViewController = (RootViewController*)self.parentViewController.parentViewController;
    
    [UIView animateWithDuration:0.2 animations:^{
        if ([self.dataObject isEqualToString:@"1"]) {
            rootViewController.view.backgroundColor = [UIColor blackColor];
            [rootViewController.orderButton setBackgroundColor:[UIColor blackColor]];
            [rootViewController.orderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [rootViewController.shareButton setTintColor:[UIColor whiteColor]];
            [rootViewController.accountButton setTintColor:[UIColor whiteColor]];
            rootViewController.shirtColor = @"white";
        }else{
            rootViewController.view.backgroundColor = [UIColor whiteColor];
            [rootViewController.orderButton setBackgroundColor:[UIColor whiteColor]];
            [rootViewController.orderButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [rootViewController.shareButton setTintColor:[UIColor blackColor]];
            [rootViewController.accountButton setTintColor:[UIColor blackColor]];
            rootViewController.shirtColor = @"black";
        }
    }];
}

@end
