//
//  ChangePasswordViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import <AFNetworking/UIKit+AFNetworking.h>
#import "FormView.h"

@interface ChangePasswordViewController () <UITextFieldDelegate>

@property (strong, nonatomic) FormView *oldPasswordFormView;
@property (strong, nonatomic) FormView *passwordFormView;
@property (strong, nonatomic) FormView *confirmPasswordFormView;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Change Password";
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonTouched:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.oldPasswordFormView = [[FormView alloc] init];
    self.oldPasswordFormView.fieldName = @"Old Password";
    self.oldPasswordFormView.textField.placeholder = @"Current Password";
    self.oldPasswordFormView.textField.returnKeyType = UIReturnKeyDone;
    self.oldPasswordFormView.textField.secureTextEntry = YES;
    self.oldPasswordFormView.textField.delegate = self;
    
    self.passwordFormView = [[FormView alloc] init];
    self.passwordFormView.fieldName = @"New Password";
    self.passwordFormView.textField.placeholder = @"At least 8 characters";
    self.passwordFormView.textField.returnKeyType = UIReturnKeyDone;
    self.passwordFormView.textField.secureTextEntry = YES;
    self.passwordFormView.textField.delegate = self;
    
    self.confirmPasswordFormView = [[FormView alloc] init];
    self.confirmPasswordFormView.fieldName = @"Confirm";
    self.confirmPasswordFormView.textField.placeholder = @"Enter password again";
    self.confirmPasswordFormView.textField.returnKeyType = UIReturnKeyDone;
    self.confirmPasswordFormView.textField.secureTextEntry = YES;
    self.confirmPasswordFormView.textField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    // scroll the search bar off-screen
    self.navigationController.navigationBar.shadowImage = nil;
}

- (void)saveButtonTouched:(id)sender
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [[AppDelegate sharedDelegate].store.currentAccount updatePassword:self.oldPasswordFormView.textField.text password:self.passwordFormView.textField.text confirmedPassword:self.confirmPasswordFormView.textField.text withCompletion:^(NSError *error) {
        
        if (!error) {
            [SVProgressHUD showSuccessWithStatus:@"Password Changed"];
//            UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your password was successfully changed." delegate:nil cancelButtonTitle:@"Onward" otherButtonTitles:nil];
//            [successAlert show];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [SVProgressHUD dismiss];
            UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:@"Failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
            [failedAlert show];
        }
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return !section ? 1 : 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, [self tableView:tableView heightForFooterInSection:section])];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    FormView *formView;
    if (!indexPath.section) {
        formView = self.oldPasswordFormView;
    }
    else {
        if (!indexPath.row) {
            formView = self.passwordFormView;
        }
        else {
            formView = self.confirmPasswordFormView;
        }
    }
    formView.frame = cell.contentView.bounds;
    [cell.contentView addSubview:formView];
    return cell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
