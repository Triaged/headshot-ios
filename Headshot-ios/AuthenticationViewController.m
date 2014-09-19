//
//  AuthenticationViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 9/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

typedef NS_ENUM(NSUInteger, AuthenticationRow)  {
    AuthenticationRowFirstName,
    AuthenticationRowLastName,
    AuthenticationRowEmail,
    AuthenticationRowPhone,
};

#import "AuthenticationViewController.h"
#import "AuthValidationViewController.h"
#import "FormView.h"
#import "HeadshotAPIClient.h"

@interface AuthenticationViewController () <UITextFieldDelegate>

@property (strong, nonatomic) FormView *firstNameFormView;
@property (strong, nonatomic) FormView *lastNameFormView;
@property (strong, nonatomic) FormView *emailFormView;
@property (strong, nonatomic) FormView *phoneFormView;
@property (strong, nonatomic) UIButton *signupButton;

@end

@implementation AuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.firstNameFormView = [[FormView alloc] initWithFieldName:@"First Name" placeholder:nil];
    self.lastNameFormView = [[FormView alloc] initWithFieldName:@"Last Name" placeholder:nil];
    self.emailFormView = [[FormView alloc] initWithFieldName:@"Email" placeholder:nil];
    self.phoneFormView = [[FormView alloc] initWithFieldName:@"Phone" placeholder:nil];
    
    for (FormView *formView in @[self.firstNameFormView, self.lastNameFormView, self.emailFormView, self.phoneFormView]) {
        formView.textField.delegate = self;
    }
    
    self.signupButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.signupButton.size = CGSizeMake(200, 100);
    [self.signupButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.signupButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 200)];
    [footerView addSubview:self.signupButton];
    self.signupButton.center = CGPointMake(footerView.width/2.0, footerView.height/2.0);
    self.tableView.tableFooterView = footerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    FormView *formView;
    if (indexPath.row == AuthenticationRowFirstName) {
        formView = self.firstNameFormView;
    }
    else if (indexPath.row == AuthenticationRowLastName) {
        formView = self.lastNameFormView;
    }
    else if (indexPath.row == AuthenticationRowEmail) {
        formView = self.emailFormView;
    }
    else if (indexPath.row == AuthenticationRowPhone) {
        formView = self.phoneFormView;
    }
    formView.frame = cell.contentView.bounds;
    formView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [cell.contentView addSubview:formView];
    return cell;
}

- (void)login
{
    NSDictionary *parameters = @{@"auth_params" :
                                     @{
                                    @"first_name" : self.firstNameFormView.textField.text,
                                   @"last_name" : self.lastNameFormView.textField.text,
                                   @"email" : self.emailFormView.textField.text,
                                   @"phone_number" : self.phoneFormView.textField.text}};
    [[HeadshotAPIClient sharedClient] POST:@"authentications" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        AuthValidationViewController *authValidationViewController = [[AuthValidationViewController alloc] init];
        authValidationViewController.userIdentifier = responseObject[@"id"];
        [self.navigationController pushViewController:authValidationViewController animated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITextField *nextTextField;
    if (textField == self.firstNameFormView.textField) {
        nextTextField = self.lastNameFormView.textField;
    }
    else if (textField == self.lastNameFormView.textField) {
        nextTextField = self.emailFormView.textField;
    }
    else if (textField == self.emailFormView.textField) {
        nextTextField = self.phoneFormView.textField;
    }
    if (nextTextField) {
        [nextTextField becomeFirstResponder];
    }
    else {
        [self login];
    }
    return YES;
}
@end
