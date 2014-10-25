//
//  AddCreditCardTableViewController.m
//  vnecks
//
//  Created by Eric Lewis on 10/20/14.
//  Copyright (c) 2014 Eric Lewis. All rights reserved.
//

#import "AddCreditCardTableViewController.h"
#import <Parse/Parse.h>
#import <SpinKit/RTSpinKitView.h>
#import "MBProgressHUD.h"
#import "Stripe.h"
#import "PTKView.h"
#import "Chuzzle.h"

@interface AddCreditCardTableViewController ()<UITextFieldDelegate> {
@private
    BOOL _isInitialState;
    BOOL _isValidState;
}

@property (weak, nonatomic) IBOutlet UITextField *cardNumberField;
@property (weak, nonatomic) IBOutlet UITextField *cardExpireDateField;
@property (weak, nonatomic) IBOutlet UITextField *cardCVCField;
@property (weak, nonatomic) IBOutlet UITextField *cardBillingAddressField;
@property (weak, nonatomic) IBOutlet UITextField *cardZipCodeField;
@property (nonatomic, readonly, assign) UIResponder *firstResponderField;
@property (nonatomic, readonly, assign) UITextField *firstInvalidField;
@property (nonatomic, readonly, assign) UITextField *nextFirstResponder;

@property (nonatomic) PTKCardNumber *cardNumber;
@property (nonatomic) PTKCardExpiry *cardExpiry;
@property (nonatomic) PTKCardCVC *cardCVC;
@property (nonatomic) PTKAddressZip *addressZip;

@end

@implementation AddCreditCardTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Add Credit Card";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    //self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)save{
    
    STPCard *card = [[STPCard alloc] init];
    card.number = self.cardNumberField.text;
    card.expMonth = 1;
    card.expYear = 16;
    card.cvc = self.cardCVCField.text;
    
    [Stripe createTokenWithCard:card
                     completion:^(STPToken *token, NSError *error) {
                         if (error) {
                             NSLog(@"%@", error);
                             
                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                         } else {
                             NSDictionary *params = @{
                                                      @"customerId" : [PFUser currentUser][@"stripeCustomerId"],
                                                      @"tokenId" : token.tokenId,
                                                      };
                             
                             [PFCloud callFunctionInBackground:@"addCardToCustomer" withParameters:params block:^(id object, NSError *error) {
                                 if (error) {
                                     NSLog(@"%@", error);
                                 }
                                 NSLog(@"%@", object);
                                 
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [self.navigationController popViewControllerAnimated:YES];
                             }];
                         }
                     }];
    
    RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleChasingDots color:[UIColor whiteColor]];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.square = YES;
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = spinner;
    
    [spinner startAnimating];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Delegates
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    if ([textField isEqual:self.cardNumberField]) {
        return [self cardNumberFieldShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    if ([textField isEqual:self.cardExpireDateField]) {
        return [self cardExpiryShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    if ([textField isEqual:self.cardCVCField]) {
        return [self cardCVCShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    return YES;
}

- (BOOL)cardNumberFieldShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.cardNumberField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    PTKCardNumber *cardNumber = [PTKCardNumber cardNumberWithString:resultString];
    
    if (![cardNumber isPartiallyValid])
        return NO;
    
    if (replacementString.length > 0) {
        self.cardNumberField.text = [cardNumber formattedStringWithTrail];
    } else {
        self.cardNumberField.text = [cardNumber formattedString];
    }
    
    if ([cardNumber isValid]) {
        [self textFieldIsValid:self.cardNumberField];
        
    } else if ([cardNumber isValidLength] && ![cardNumber isValidLuhn]) {
        [self textFieldIsInvalid:self.cardNumberField withErrors:YES];
        
    } else if (![cardNumber isValidLength]) {
        [self textFieldIsInvalid:self.cardNumberField withErrors:NO];
    }
    
    return NO;
}

- (BOOL)cardExpiryShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.cardExpireDateField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    PTKCardExpiry *cardExpiry = [PTKCardExpiry cardExpiryWithString:resultString];
    
    if (![cardExpiry isPartiallyValid]) return NO;
    
    // Only support shorthand year
    if ([cardExpiry formattedString].length > 5) return NO;
    
    if (replacementString.length > 0) {
        self.cardExpireDateField.text = [cardExpiry formattedStringWithTrail];
    } else {
        self.cardExpireDateField.text = [cardExpiry formattedString];
    }
    
    if ([cardExpiry isValid]) {
        [self textFieldIsValid:self.cardExpireDateField];
        
    } else if ([cardExpiry isValidLength] && ![cardExpiry isValidDate]) {
        [self textFieldIsInvalid:self.cardExpireDateField withErrors:YES];
    } else if (![cardExpiry isValidLength]) {
        [self textFieldIsInvalid:self.cardExpireDateField withErrors:NO];
    }
    
    return NO;
}

- (BOOL)cardCVCShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.cardCVCField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    PTKCardCVC *cardCVC = [PTKCardCVC cardCVCWithString:resultString];
    PTKCardType cardType = [[PTKCardNumber cardNumberWithString:self.cardNumberField.text] cardType];
    
    // Restrict length
    if (![cardCVC isPartiallyValidWithType:cardType]) return NO;
    
    // Strip non-digits
    self.cardCVCField.text = [cardCVC string];
    
    if ([cardCVC isValidWithType:cardType]) {
        [self textFieldIsValid:self.cardCVCField];
    } else {
        [self textFieldIsInvalid:self.cardCVCField withErrors:NO];
    }
    
    return NO;
}

#pragma mark - Validations

- (void)checkValid
{
    if ([self isValid]) {
        _isValidState = YES;
       
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
    } else if (![self isValid] && _isValidState) {
        _isValidState = NO;
        
        self.navigationItem.rightBarButtonItem.enabled = NO;

    }
}

- (BOOL)isValid
{
    return [self.cardNumber isValid] && [self.cardExpiry isValid] &&
    [self.cardCVC isValidWithType:self.cardNumber.cardType] && self.cardBillingAddressField.text.chuzzle && self.cardZipCodeField.chuzzle;
}

- (void)textFieldIsValid:(UITextField *)textField
{
    textField.textColor = [UIColor blackColor];
    [self checkValid];
}

- (void)textFieldIsInvalid:(UITextField *)textField withErrors:(BOOL)errors
{
    if (errors) {
        textField.textColor = [UIColor redColor];
    } else {
        textField.textColor = [UIColor blackColor];
    }
    [self checkValid];
}

#pragma mark -
#pragma mark UIResponder
- (UIResponder *)firstResponderField;
{
    NSArray *responders = @[self.cardNumberField, self.cardExpireDateField, self.cardCVCField];
    for (UIResponder *responder in responders) {
        if (responder.isFirstResponder) {
            return responder;
        }
    }
    
    return nil;
}

- (UITextField *)firstInvalidField;
{
    if (![[PTKCardNumber cardNumberWithString:self.cardNumberField.text] isValid])
        return self.cardNumberField;
    else if (![[PTKCardExpiry cardExpiryWithString:self.cardExpireDateField.text] isValid])
        return self.cardExpireDateField;
    else if (![[PTKCardCVC cardCVCWithString:self.cardCVCField.text] isValid])
        return self.cardCVCField;
    
    return nil;
}

- (UITextField *)nextFirstResponder;
{
    if (self.firstInvalidField)
        return self.firstInvalidField;
    
    return self.cardCVCField;
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

#pragma mark - Accessors

- (PTKCardNumber *)cardNumber
{
    return [PTKCardNumber cardNumberWithString:self.cardNumberField.text];
}

- (PTKCardExpiry *)cardExpiry
{
    return [PTKCardExpiry cardExpiryWithString:self.cardExpireDateField.text];
}

- (PTKCardCVC *)cardCVC
{
    return [PTKCardCVC cardCVCWithString:self.cardCVCField.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
