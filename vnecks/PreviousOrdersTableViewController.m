//
//  PreviousOrdersTableViewController.m
//  vnecks
//
//  Created by Eric Lewis on 10/20/14.
//  Copyright (c) 2014 Eric Lewis. All rights reserved.
//

#import "PreviousOrdersTableViewController.h"
#import <Parse/Parse.h>
#import "NSDate+TimeAgo.h"
#import "SSArrayDataSource.h"
#import <SpinKit/RTSpinKitView.h>
#import "MBProgressHUD.h"

@interface PreviousOrdersTableViewController ()
@property (nonatomic, strong) SSArrayDataSource *orderDataSource;
@end

@implementation PreviousOrdersTableViewController

static NSString * const reuseIdentifier = @"PreviousOrderCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Previous Orders";
    self.tableView.tableFooterView = [UIView new];
    
    self.orderDataSource = [[SSArrayDataSource alloc] initWithItems:@[]];
    
    UILabel *noItemsLabel = [UILabel new];
    noItemsLabel.text = @"No previous orders";
    noItemsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
    noItemsLabel.textAlignment = NSTextAlignmentCenter;
    self.orderDataSource.emptyView = noItemsLabel;
    
    self.orderDataSource.cellCreationBlock = ^id(PFObject *order,
                                                  UITableView *tableView,
                                                  NSIndexPath *indexPath) {
        return [tableView dequeueReusableCellWithIdentifier:@"OrderCell"];
    };
    
    self.orderDataSource.cellConfigureBlock = ^(UITableViewCell *cell,
                                                PFObject *order,
                                                UITableView *tableView,
                                                NSIndexPath *indexPath) {
        cell.detailTextLabel.text = [order.updatedAt timeAgo];
        if ([order[@"shipped"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            cell.textLabel.text = [NSString stringWithFormat:@"Shipped %@ %@ shirt(s)", order[@"quantity"], order[@"color"]];
        }else{
            cell.textLabel.text = [NSString stringWithFormat:@"Ordered %@ %@ shirt(s)", order[@"quantity"], order[@"color"]];
        }
    };
    
    self.orderDataSource.tableActionBlock = ^BOOL(SSCellActionType action,
                                                              UITableView *tableView,
                                                              NSIndexPath *indexPath) {
        return NO;
    };
    
    self.orderDataSource.tableView = self.tableView;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Order"];
    [query whereKey:@"email" equalTo:[[PFUser currentUser] email]];
    [query whereKey:@"fulfilled" equalTo:[NSNumber numberWithBool:YES]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.orderDataSource updateItems:[[objects reverseObjectEnumerator] allObjects]];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleChasingDots color:[UIColor whiteColor]];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.square = YES;
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = spinner;
    
    [spinner startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
