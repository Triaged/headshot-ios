//
//  LoginViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/7/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "LoginViewController.h"
#import "UIControl+NextControl.h"
#import "BAFormView.h"

typedef NS_ENUM(NSInteger, LoginRow) {
    LoginRowEmail,
    LoginRowPassword,
};

@interface LoginViewController() <UITextFieldDelegate>

@property (strong, nonatomic) BAFormView *emailFormView;
@property (strong, nonatomic) BAFormView *passwordFormView;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *loginButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(loginButtonTouched:)];
    self.navigationItem.rightBarButtonItem = loginButtonItem;
    
    self.tableView.rowHeight = 57;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.emailFormView = [[BAFormView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.tableView.rowHeight) title:@"Email" placeholder:@"you@domain.com"];
    self.emailFormView.textField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailFormView.textField.returnKeyType = UIReturnKeyNext;
    self.emailFormView.textField.delegate = self;
    
    self.passwordFormView = [[BAFormView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.tableView.rowHeight) title:@"Password" placeholder:@"Password"];
    self.passwordFormView.textField.secureTextEntry = YES;
    self.passwordFormView.textField.delegate = self;
    
    self.emailFormView.textField.nextControl = self.passwordFormView.textField;
    
}

- (void)loginButtonTouched:(id)sender
{
    NSString *email = self.emailFormView.textField.text;
    NSString *password  =self.passwordFormView.textField.text;
    if (email && password) {
        [self loginEmail:email password:password];
    }
}

- (void)loginEmail:(NSString *)email password:(NSString *)password
{
    [SVProgressHUD show];
    [Account loginWithEmail:email password:password completion:^(Account *account, NSError *error) {
        [SVProgressHUD dismiss];
        
        if (error) {
        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        else {
            
        }
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
    if (indexPath.row == LoginRowEmail) {
        cell = [self configureEmailCell:cell];
    }
    else if (indexPath.row == LoginRowPassword) {
        cell = [self configurePasswordCell:cell];
    }
    return cell;
}

- (UITableViewCell *)configureEmailCell:(UITableViewCell *)cell
{
    [cell.contentView addSubview:self.emailFormView];
    [self.emailFormView addEdge:UIRectEdgeBottom
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
        [self loginButtonTouched:nil];
    }
    return NO;
}

@end
