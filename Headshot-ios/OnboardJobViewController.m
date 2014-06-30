//
//  OnboardJobViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OnboardJobViewController.h"
#import "OnboardSelectDepartmentViewController.h"
#import "OnboardSelectManagersViewControllers.h"
#import "Department.h"
#import "EmployeeInfo.h"
#import "FormView.h"

typedef NS_ENUM(NSUInteger, JobTableRow)  {
    JobTableRowTitle = 0,
    JobTableRowDepartment,
    JobTableRowManager,
};

@interface OnboardJobViewController () <UITextFieldDelegate, OnboardSelectDepartmentViewControllerDelegate, SelectManagersViewControllerDelegate>

@property (strong, nonatomic) FormView *jobTitleFormView;
@property (strong, nonatomic) FormView *departmentFormView;
@property (strong, nonatomic) FormView *managerFormView;
@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) Department *selectedDepartment;
@property (strong, nonatomic) OnboardSelectManagersViewControllers *selectManagersViewController;
@property (strong, nonatomic) OnboardSelectDepartmentViewController *selectDepartmentViewController;

@end

@implementation OnboardJobViewController

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 249)];
    UIImageView *jobImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"onboarding-job"]];
    jobImageView.centerX = headerView.width/2.0;
    jobImageView.y = 30;
    [headerView addSubview:jobImageView];
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.size = CGSizeMake(236, 80);
    descriptionLabel.centerX = headerView.width/2.0;
    descriptionLabel.y = jobImageView.bottom;
    descriptionLabel.numberOfLines = 2;
    descriptionLabel.text = @"Tell us more about position";
    descriptionLabel.font = [ThemeManager regularFontOfSize:24];
    descriptionLabel.textColor = [[ThemeManager sharedTheme] greenColor];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:descriptionLabel];
    self.tableView.tableHeaderView = headerView;
    
    self.jobTitleFormView = [[FormView alloc] init];
    self.jobTitleFormView.fieldName = @"Title";
    self.jobTitleFormView.textField.placeholder = @"Your Job Title";
    self.jobTitleFormView.textField.delegate = self;
    
    self.departmentFormView = [[FormView alloc] init];
    self.departmentFormView.fieldName = @"Department";
    self.departmentFormView.userInteractionEnabled = NO;
    
    self.managerFormView = [[FormView alloc] init];
    self.managerFormView.fieldName = @"Reporting to";
    self.managerFormView.userInteractionEnabled = NO;
 
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 123)];
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextButton.size = CGSizeMake(self.view.width, 60);
    self.nextButton.bottom = footerView.height;
    self.nextButton.backgroundColor = [[ThemeManager sharedTheme] orangeColor];
    [self.nextButton setTitle:@"Continue" forState:UIControlStateNormal];
    self.nextButton.titleLabel.font = [ThemeManager regularFontOfSize:18];
    [self.nextButton addTarget:self action:@selector(nextButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:self.nextButton];
    self.tableView.tableFooterView = footerView;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    User *user = [AppDelegate sharedDelegate].store.currentAccount.currentUser;
    self.jobTitleFormView.textField.text = user.employeeInfo.jobTitle;
    if (user.department) {
        self.departmentFormView.textField.text = user.department.name;
    }
    if (user.manager) {
        self.managerFormView.textField.text = user.manager.fullName;
    }
}

- (void)nextButtonTouched:(id)sender
{
    NSString *jobTitle = self.jobTitleFormView.textField.text;
    [AppDelegate sharedDelegate].store.currentAccount.currentUser.employeeInfo.jobTitle = jobTitle;
    
    if ([self.delegate respondsToSelector:@selector(onboardViewController:doneButtonTouched:)]) {
        [self.delegate onboardViewController:self doneButtonTouched:sender];
    }
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    FormView *formView;
    UITableViewCellAccessoryType accesoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row == JobTableRowTitle) {
        formView = self.jobTitleFormView;
    }
    else if (indexPath.row == JobTableRowDepartment) {
        formView = self.departmentFormView;
        accesoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == JobTableRowManager) {
        formView = self.managerFormView;
        accesoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell.contentView addSubview:formView];
    formView.frame = cell.contentView.bounds;
    cell.accessoryType = accesoryType;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == JobTableRowDepartment) {
        self.selectDepartmentViewController = [[OnboardSelectDepartmentViewController alloc] init];
        self.selectDepartmentViewController.delegate = self;
        [self presentViewControllerWithNav:self.selectDepartmentViewController animated:YES completion:nil];
    }
    else if (indexPath.row == JobTableRowManager) {
        self.selectManagersViewController = [[OnboardSelectManagersViewControllers alloc] init];
        self.selectManagersViewController.delegate = self;
        [self presentViewControllerWithNav:self.selectManagersViewController animated:YES completion:nil];
    }
}

#pragma mark - Select Department View Controller Delegate
- (void)OnboardSelectDepartmentViewController:(OnboardSelectDepartmentViewController *)selectDepartmentViewController didSelectDepartment:(Department *)department
{
    self.selectedDepartment = department;
    self.departmentFormView.textField.text = department.name;
    [AppDelegate sharedDelegate].store.currentAccount.currentUser.department = department;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelSelectDepartmentViewController:(OnboardSelectDepartmentViewController *)selectDepartmentViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Select Managers View Controller Delegate
- (void)selectManagersViewController:(OnboardSelectManagersViewControllers *)selectManagersViewController didSelectUser:(User *)user
{
    self.managerFormView.textField.text = user.fullName;
    [AppDelegate sharedDelegate].store.currentAccount.currentUser.manager = user;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelSelectManagersViewController:(OnboardSelectManagersViewControllers *)selectManagersViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
