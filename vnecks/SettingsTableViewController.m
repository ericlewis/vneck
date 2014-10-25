//
//  SettingsViewController.m
//  vnecks
//
//  Created by Eric Lewis on 10/20/14.
//  Copyright (c) 2014 Eric Lewis. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "RootViewController.h"
#import "VTAcknowledgementsViewController.h"
#import "Helpshift.h"
#import <Parse/Parse.h>
#import "ActionSheetStringPicker.h"
#import <SpinKit/RTSpinKitView.h>
#import "MBProgressHUD.h"

@interface SettingsTableViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>{
    NSArray *_pickerData;
}

@property (weak, nonatomic) IBOutlet UILabel *shirtSizeLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *supportCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *cocoapodCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *shirtSizeCell;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
    self.clearsSelectionOnViewWillAppear = YES;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    
    PFUser *currentUser = [PFUser currentUser];
    
    self.shirtSizeLabel.text = [self stringForResult:currentUser[@"size"]];
    
    // Initialize Data
    _pickerData = @[@"Small", @"Medium", @"Large", @"X-Large"];
}

- (NSString *)stringForResult:(NSString*)string{
    if (string) {
        return string;
    }
    
    return @"none";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.cocoapodCell) {
        VTAcknowledgementsViewController *viewController = [VTAcknowledgementsViewController acknowledgementsViewController];
        viewController.licenseTextViewFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        viewController.tableView.backgroundColor = self.tableView.backgroundColor;
        [self.navigationController pushViewController:viewController animated:YES];
    }else if (cell == self.supportCell){
        [[Helpshift sharedInstance] showConversation:self withOptions:nil];
    }else if(cell == self.shirtSizeCell){
        
        int indexValue = [_pickerData indexOfObject:[PFUser currentUser][@"size"]];
        
        [ActionSheetStringPicker showPickerWithTitle:@"Select your size"
                                                rows:_pickerData
                                    initialSelection:indexValue
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               self.shirtSizeLabel.text = selectedValue;
                                               
                                               [[PFUser currentUser] setObject:selectedValue forKey:@"size"];
                                               [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                   if (!error) {
                                                       self.shirtSizeLabel.text = [self stringForResult:[PFUser currentUser][@"size"]];
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
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"Block Picker Canceled");
                                         }
                                              origin:self.view];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"ShowLoginFromLogout"]) {
        [PFUser logOut];
        
        if ([[self.parentViewController.childViewControllers firstObject] isKindOfClass:[RootViewController class]]) {
            RootViewController *rootView = (RootViewController*)[self.parentViewController.childViewControllers firstObject];
            rootView.view.alpha = 0;
        }
    }
}

@end
