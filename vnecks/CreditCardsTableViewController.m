//
//  CreditCardsTableViewController.m
//  vnecks
//
//  Created by Eric Lewis on 10/20/14.
//  Copyright (c) 2014 Eric Lewis. All rights reserved.
//

#import "CreditCardsTableViewController.h"
#import <Parse/Parse.h>
#import <SpinKit/RTSpinKitView.h>
#import "MBProgressHUD.h"
#import "SSArrayDataSource.h"

@interface CreditCardsTableViewController ()
@property (nonatomic, strong) SSArrayDataSource *cardDataSource;
@end

@implementation CreditCardsTableViewController

static NSString * const reuseIdentifier = @"CardCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"My Credit Cards";
    
    self.tableView.tableFooterView = [UIView new];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCreditCard)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    
    self.cardDataSource = [[SSArrayDataSource alloc] initWithItems:@[]];
    
    UILabel *noItemsLabel = [UILabel new];
    noItemsLabel.text = @"No credit cards. Tap the + to add one.";
    noItemsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
    noItemsLabel.textAlignment = NSTextAlignmentCenter;
    self.cardDataSource.emptyView = noItemsLabel;
    
    self.cardDataSource.cellCreationBlock = ^id(PFObject *order,
                                                 UITableView *tableView,
                                                 NSIndexPath *indexPath) {
        return [tableView dequeueReusableCellWithIdentifier:@"CardCell"];
    };
    
    self.cardDataSource.cellConfigureBlock = ^(UITableViewCell *cell,
                                                PFObject *card,
                                                UITableView *tableView,
                                                NSIndexPath *indexPath) {
        cell.textLabel.text = card[@"brand"];
        cell.detailTextLabel.text = card[@"last4"];
    };
    
    __weak typeof(self)weakSelf = self;

    self.cardDataSource.tableDeletionBlock = ^(SSArrayDataSource *cardDataSource,
                                              UITableView *tableView,
                                              NSIndexPath *indexPath) {
        
        PFObject *order = [cardDataSource itemAtIndexPath:indexPath];
        
        [PFCloud callFunctionInBackground:@"removeCardForCustomer" withParameters:@{@"customerId": [PFUser currentUser][@"stripeCustomerId"], @"cardId" : order[@"id"]} block:^(id object, NSError *error) {
            if (!error) {
                [cardDataSource removeItemAtIndex:indexPath.row];
            }else{
                NSLog(@"%@", error);
            }
            
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }];
        
        
        RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleChasingDots color:[UIColor whiteColor]];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        hud.square = YES;
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = spinner;
        
        [spinner startAnimating];
    };

    
    self.cardDataSource.tableView = self.tableView;
}

- (void)viewWillAppear:(BOOL)animated{
    [PFCloud callFunctionInBackground:@"listCardsForCustomer" withParameters:@{@"customerId" : [PFUser currentUser][@"stripeCustomerId"]} block:^(id object, NSError *error) {
        if (!error) {
            [self.cardDataSource updateItems:object];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }        
    }];
    
    RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleChasingDots color:[UIColor whiteColor]];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.square = YES;
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = spinner;
    
    [spinner startAnimating];
}

- (void)addCreditCard{
    [self performSegueWithIdentifier:@"ShowAddCreditCard" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
