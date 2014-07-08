//
//  ForgotPasswordViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/8/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "FormView.h"

@interface ForgotPasswordViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UIButton *submitButton;
@property (strong, nonatomic) FormView *emailFormView;

@end

@implementation ForgotPasswordViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    descriptionLabel.text = @"Forgot your password?";
    descriptionLabel.numberOfLines = 2;
    descriptionLabel.font = [ThemeManager regularFontOfSize:18];
    descriptionLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    [headerView addSubview:descriptionLabel];
    self.tableView.tableHeaderView = headerView;
    
    
    self.emailFormView = [[FormView alloc] initWithFieldName:@"Email" placeholder:@"Your Company Email Address"];
    self.emailFormView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailFormView.textField.delegate = self;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 118)];
    self.submitButton = [[UIButton alloc] init];
    self.submitButton.size = CGSizeMake(280, 50);
    self.submitButton.centerX = footerView.width/2.0;
    self.submitButton.centerY = footerView.height/2.0;
    self.submitButton.backgroundColor = [[ThemeManager sharedTheme] orangeColor];
    [self.submitButton setTitle:@"Reset Password" forState:UIControlStateNormal];
    self.submitButton.titleLabel.font = [ThemeManager regularFontOfSize:18];
    self.submitButton.layer.cornerRadius = 2;
    [self.submitButton addTarget:self action:@selector(submitButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:self.submitButton];
    self.tableView.tableFooterView = footerView;
}

- (void)submitButtonTouched:(id)sender
{
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.contentView addSubview:self.emailFormView];
    self.emailFormView.frame = cell.contentView.bounds;
    [cell addEdge:(UIRectEdgeTop | UIRectEdgeBottom) width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
    return cell;
}

#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

@end
