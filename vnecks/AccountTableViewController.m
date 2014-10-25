//
//  AccountTableViewController.m
//  vnecks
//
//  Created by Eric Lewis on 10/20/14.
//  Copyright (c) 2014 Eric Lewis. All rights reserved.
//

#import "AccountTableViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Chuzzle.h"

@interface AccountTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (weak, nonatomic) IBOutlet UILabel *address1Label;
@property (weak, nonatomic) IBOutlet UILabel *address2Label;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *zipCodeLabel;

@end

@implementation AccountTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Accounts & Shipping";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    PFUser *currentUser = [PFUser currentUser];

    self.fullNameLabel.text = [self stringForResult:currentUser[@"name"]];
    self.emailLabel.text = [self stringForResult:currentUser.email];
    
    self.address1Label.text = [self stringForResult:currentUser[@"address1"]];
    self.address2Label.text = [self stringForResult:currentUser[@"address2"]];
    self.cityLabel.text = [self stringForResult:currentUser[@"city"]];
    self.stateLabel.text = [self stringForResult:currentUser[@"state"]];
    self.zipCodeLabel.text = [self stringForResult:currentUser[@"zipcode"]];
    
    
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}

- (NSString *)stringForResult:(NSString*)string{
    if (string.chuzzle) {
        return string;
    }
    
    return @"none";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
