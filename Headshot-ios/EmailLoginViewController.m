//
//  EmailLoginViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "EmailLoginViewController.h"
#import <AFNetworking/UIKit+AFNetworking.h>
#import "FormView.h"
#import "CredentialStore.h"
#import "TRDataStoreManager.h"
#import "Store.h"

@interface EmailLoginViewController () <UITextFieldDelegate>

@property (strong, nonatomic) FormView *emailFormView;
@property (strong, nonatomic) FormView *passwordFormView;
@property (strong, nonatomic) UIButton *loginButton;

@end

@implementation EmailLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 189)];
    UILabel *loginLabel = [[UILabel alloc] init];
    loginLabel.size = CGSizeMake(self.view.width, 40);
    loginLabel.y = 44;
    loginLabel.textAlignment = NSTextAlignmentCenter;
    loginLabel.font = [ThemeManager regularFontOfSize:36];
    loginLabel.textColor = [[ThemeManager sharedTheme] greenColor];
    loginLabel.text = @"Badge";
    [headerView addSubview:loginLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.size = CGSizeMake(186, 48);
    descriptionLabel.y = loginLabel.bottom + 20;
    descriptionLabel.centerX = headerView.width/2.0;
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.text = @"Log in with your company email address";
    descriptionLabel.numberOfLines = 2;
    descriptionLabel.font = [ThemeManager regularFontOfSize:18];
    descriptionLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    [headerView addSubview:descriptionLabel];
    self.tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 118)];
    self.loginButton = [[UIButton alloc] init];
    self.loginButton.size = CGSizeMake(280, 50);
    self.loginButton.centerX = footerView.width/2.0;
    self.loginButton.centerY = footerView.height/2.0;
    self.loginButton.backgroundColor = [[ThemeManager sharedTheme] orangeColor];
    [self.loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [ThemeManager regularFontOfSize:18];
    self.loginButton.layer.cornerRadius = 2;
    [self.loginButton addTarget:self action:@selector(loginButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:self.loginButton];
    self.tableView.tableFooterView = footerView;
    
    self.emailFormView = [[FormView alloc] init];
    self.emailFormView.fieldName = @"Email";
    self.emailFormView.textField.placeholder = @"Your Company Email Address";
    self.emailFormView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailFormView.textField.returnKeyType = UIReturnKeyDone;
    self.emailFormView.textField.delegate = self;
    
    self.passwordFormView = [[FormView alloc] init];
    self.passwordFormView.fieldName = @"Password";
    self.passwordFormView.textField.returnKeyType = UIReturnKeyDone;
    self.passwordFormView.textField.secureTextEntry = YES;
    self.passwordFormView.textField.delegate = self;
}

- (void)loginButtonTouched:(id)sender
{
    [SVProgressHUD show];
    
    id params = @{@"user_login" : @{
                          @"email": self.emailFormView.textField.text,
                          @"password": self.passwordFormView.textField.text
                          }};
    

    [[HeadshotAPIClient sharedClient] POST:@"sessions/" parameters:params success:^(NSURLSessionDataTask *task, id JSON) {
        
        // Set Auth Code
        NSString *authToken = [JSON valueForKeyPath:@"authentication_token"];
        Account *account = [Account updatedObjectWithRawJSONDictionary:JSON inManagedObjectContext:[TRDataStoreManager sharedInstance].mainThreadManagedObjectContext];
        [[CredentialStore sharedClient] setAuthToken:authToken];
        [[AppDelegate sharedDelegate].store userLoggedInWithAccount:account];
        [SVProgressHUD dismiss];
        [self didLogin];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
        [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    }];
}

- (void)didLogin
{
    if ([self.delegate respondsToSelector:@selector(onboardViewController:doneButtonTouched:)]) {
        [self.delegate onboardViewController:self doneButtonTouched:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    FormView *formView;
    if (!indexPath.row) {
        formView = self.emailFormView;
    }
    else {
        formView = self.passwordFormView;
    }
    [cell.contentView addSubview:formView];
    formView.frame = cell.contentView.bounds;
    CGFloat edgeWidth = 0.5;
    UIColor *edgeColor = [UIColor colorWithWhite:225/255.0 alpha:1.0];
    [formView addEdge:(UIRectEdgeTop) width:edgeWidth color:edgeColor];
    if (indexPath.row) {
        [formView addEdge:UIRectEdgeBottom width:edgeWidth color:edgeColor];
    }
    
    return cell;
}

#pragma mark - UITextFieldDelegegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
