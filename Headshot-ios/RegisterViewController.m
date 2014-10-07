//
//  RegisterViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/1/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "RegisterViewController.h"
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import "PhotoManager.h"
#import "UIControl+NextControl.h"
#import "AuthValidationViewController.h"
#import "BAFormView.h"

typedef NS_ENUM(NSInteger, RegisterRow) {
    RegisterRowName,
    RegisterRowEmail,
    RegisterRowPhone,
    RegisterRowPassword,
};

@interface RegisterViewController () <UITextFieldDelegate>

@property (strong, nonatomic) BAFormView *firstNameFormView;
@property (strong, nonatomic) BAFormView *lastNameFormView;
@property (strong, nonatomic) BAFormView *emailFormView;
@property (strong, nonatomic) BAFormView *phoneFormView;
@property (strong, nonatomic) BAFormView *passwordFormView;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
    cancelButtonItem.tintColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *joinButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Join" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTouched:)];
    self.navigationItem.rightBarButtonItem = joinButtonItem;
    
    
    self.navigationItem.title = @"Create Account";
    
    self.firstNameFormView = [self formViewWithTitle:@"First Name" placeHolder:@"First Name" width:self.view.width/2.0];

    self.lastNameFormView = [self formViewWithTitle:@"Last Name" placeHolder:@"Last Name" width:self.view.width/2.0];

    self.emailFormView = [self formViewWithTitle:@"Email" placeHolder:@"you@domain.com" width:self.view.width];
    self.emailFormView.textField.keyboardType = UIKeyboardTypeEmailAddress;
    
    self.phoneFormView = [self formViewWithTitle:@"Phone" placeHolder:@"(100) 123-4567" width:self.view.width];
    self.phoneFormView.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneFormView.textField.inputAccessoryView = [[TRKeyboardAccessoryView alloc] initWithCancel:^{
        [self.phoneFormView.textField resignFirstResponder];
    } doneBlock:^{
        [self.phoneFormView.textField.nextControl becomeFirstResponder];
    }];;
    
    self.passwordFormView = [self formViewWithTitle:@"Password" placeHolder:@"password at least 8 characters long" width:self.view.width];
    self.passwordFormView.textField.secureTextEntry = YES;
    
    self.firstNameFormView.textField.nextControl = self.lastNameFormView.textField;
    self.lastNameFormView.textField.nextControl = self.emailFormView.textField;
    self.emailFormView.textField.nextControl = self.phoneFormView.textField;
    self.phoneFormView.textField.nextControl = self.passwordFormView.textField;
    
    for (BAFormView *formView in @[self.firstNameFormView, self.lastNameFormView, self.emailFormView, self.phoneFormView, self.passwordFormView]) {
        UITextField *textField = formView.textField;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.delegate = self;
        if (textField.nextControl) {
            textField.returnKeyType = UIReturnKeyNext;
        }
        else {
            textField.returnKeyType = UIReturnKeyDone;
        }
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.tableFooterView = nil;
}

- (BAFormView *)formViewWithTitle:(NSString *)title placeHolder:(NSString *)placeholder width:(CGFloat)width
{
    BAFormView *formView = [[BAFormView alloc] initWithFrame:CGRectMake(0, 0, width, [self formViewHeight]) title:title placeholder:placeholder];
    return formView;
}

- (void)doneButtonTouched:(id)sender
{
    [self validateFields:^(BOOL valid, NSString *message) {
        if (valid) {
            [self loginWithFirstName:self.firstNameFormView.textField.text lastName:self.lastNameFormView.textField.text email:self.emailFormView.textField.text phone:self.phoneFormView.textField.text password:self.passwordFormView.textField.text];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (void)validateFields:(void (^)(BOOL valid, NSString *message))validationBlock
{
    BOOL valid = YES;
    NSString *message;
    if (!isValidPhone(self.phoneFormView.textField.text)) {
        valid = NO;
        message = @"Please enter a valid phone number";
    }
    if (validationBlock) {
        validationBlock(valid, message);
    }
}

- (void)loginWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email phone:(NSString *)phone password:(NSString *)password
{
    [SVProgressHUD show];
    NSDictionary *parameters = @{@"registration" :
                                     @{@"first_name" : firstName,
                                       @"last_name" : lastName,
                                       @"email" : email,
                                       @"phone_number" : phone,
                                       @"password" : password}};
    [[HeadshotAPIClient sharedClient] POST:@"registrations" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [SVProgressHUD dismiss];
        AuthValidationViewController *authValidationViewController = [[AuthValidationViewController alloc] init];
        authValidationViewController.userIdentifier = responseObject[@"id"];
        [self.navigationController pushViewController:authValidationViewController animated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [SVProgressHUD dismiss];
    }];
}


#pragma mark - Table view data source

- (CGFloat)formViewHeight
{
    return 57;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self formViewHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == RegisterRowName) {
        cell = [self configureNameCell:cell];
    }
    else if (indexPath.row == RegisterRowEmail) {
        cell = [self configureEmailCell:cell];
    }
    else if (indexPath.row == RegisterRowPhone) {
        cell = [self configurePhoneCell:cell];
    }
    else if (indexPath.row == RegisterRowPassword) {
        cell = [self configurePasswordCell:cell];
    }
    return cell;
}

- (UITableViewCell *)configureNameCell:(UITableViewCell *)cell
{
    [cell.contentView addSubview:self.firstNameFormView];
    [cell.contentView addSubview:self.lastNameFormView];
    self.lastNameFormView.x = self.firstNameFormView.right;
    [self.firstNameFormView addEdge:UIRectEdgeRight insets:UIEdgeInsetsMake(12, 0, 0, 0) width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
    return cell;
}

- (UITableViewCell *)configureEmailCell:(UITableViewCell *)cell
{
    [cell.contentView addSubview:self.emailFormView];
    [self.emailFormView addEdge:(UIRectEdgeTop | UIRectEdgeBottom)
                    insets:UIEdgeInsetsMake(0, 12, 0, 12) width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
    return cell;
}

- (UITableViewCell *)configurePhoneCell:(UITableViewCell *)cell
{
    [cell.contentView addSubview:self.phoneFormView];
    [self.phoneFormView addEdge:UIRectEdgeBottom
                         insets:UIEdgeInsetsMake(0, 12, 0, 12) width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
    return cell;
}

- (UITableViewCell *)configurePasswordCell:(UITableViewCell *)cell
{
    [cell.contentView addSubview:self.passwordFormView];
    [self.passwordFormView addEdge:UIRectEdgeBottom
                         insets:UIEdgeInsetsMake(0, 12, 0, 12) width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
    return cell;
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.nextControl) {
        [textField.nextControl becomeFirstResponder];
    }
    else {
        [self doneButtonTouched:nil];
    }
    return NO;
}


@end
