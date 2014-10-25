//
//  EditShippingTableViewController.m
//  vnecks
//
//  Created by Eric Lewis on 10/20/14.
//  Copyright (c) 2014 Eric Lewis. All rights reserved.
//

#import "EditShippingTableViewController.h"
#import <Parse/Parse.h>
#import <SpinKit/RTSpinKitView.h>
#import "MBProgressHUD.h"
#import "Chuzzle.h"

@interface EditShippingTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *address1Field;
@property (weak, nonatomic) IBOutlet UITextField *address2Field;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UITextField *zipCodeField;
@property (weak, nonatomic) IBOutlet UITableViewCell *saveButtonCell;

@end

@implementation EditShippingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Edit Shipping";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.address1Field becomeFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.saveButtonCell) {
        
        if (self.address1Field.text.chuzzle && self.cityField.text.chuzzle && self.stateField.text.chuzzle && self.zipCodeField.text.chuzzle) {
            PFUser *currentUser = [PFUser currentUser];
            [currentUser setObject:self.address1Field.text forKey:@"address1"];
            [currentUser setObject:self.address2Field.text forKey:@"address2"];
            [currentUser setObject:self.cityField.text forKey:@"city"];
            [currentUser setObject:self.stateField.text forKey:@"state"];
            [currentUser setObject:self.zipCodeField.text forKey:@"zipcode"];
            
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleChasingDots color:[UIColor whiteColor]];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.square = YES;
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = spinner;
            
            [spinner startAnimating];
        }else{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }

    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [[self firstInvalidField] becomeFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark UIResponder
- (UIResponder *)firstResponderField;
{
    NSArray *responders = @[self.address1Field, self.address2Field, self.cityField, self.stateField, self.zipCodeField];
    for (UIResponder *responder in responders) {
        if (responder.isFirstResponder) {
            return responder;
        }
    }
    
    return nil;
}

- (UITextField *)firstInvalidField;
{
    
    if (!self.address1Field.text.chuzzle) {
        return self.address1Field;
    }else if (!self.address2Field.text.chuzzle){
        return self.address2Field;
    }else if (!self.cityField.text.chuzzle){
        return self.cityField;
    }else if (!self.stateField.text.chuzzle){
        return self.stateField;
    }else if (!self.zipCodeField.text.chuzzle){
        return self.zipCodeField;
    }
    
    return nil;
}

- (UITextField *)nextFirstResponder;
{
    if (self.firstInvalidField)
        return self.firstInvalidField;
    
    return self.address1Field;
}

- (BOOL)isFirstResponder;
{
    return self.firstResponderField.isFirstResponder;
}

- (BOOL)canBecomeFirstResponder;
{
    return self.nextFirstResponder.canBecomeFirstResponder;
}

- (BOOL)becomeFirstResponder;
{
    return [self.nextFirstResponder becomeFirstResponder];
}

- (BOOL)canResignFirstResponder;
{
    return self.firstResponderField.canResignFirstResponder;
}

- (BOOL)resignFirstResponder;
{
    return [self.firstResponderField resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
