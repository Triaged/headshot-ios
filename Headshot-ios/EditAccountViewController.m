    //
//  EditProfileViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/22/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "EditAccountViewController.h"
#import <AFNetworking/UIKit+AFNetworking.h>
#import <BlocksKit+UIKit.h>
#import "HeadshotAPIClient.h"
#import "OnboardSelectDepartmentViewController.h"
#import "OnboardSelectManagersViewControllers.h"
#import "OfficesViewController.h"
#import "EditAvatarImageView.h"
#import "FormView.h"
#import "PhotoManager.h"
#import "User.h"
#import "Department.h"
#import "OfficeLocation.h"
#import "EmployeeInfo.h"
#import "DatePickerModalView.h"
#import "CommonMacros.h"

@interface EditAccountViewController () <UITextFieldDelegate, OnboardSelectDepartmentViewControllerDelegate, SelectManagersViewControllerDelegate, OfficesViewControllerDelegate, PMEDatePickerDelegate>

@property (strong, nonatomic) EditAvatarImageView *avatarImageView;
@property (strong, nonatomic) FormView *firstNameFormView;
@property (strong, nonatomic) FormView *lastNameFormView;
@property (strong, nonatomic) FormView *emailFormView;
@property (strong, nonatomic) FormView *workPhoneFormView;
@property (strong, nonatomic) FormView *homePhoneFormView;
@property (strong, nonatomic) FormView *jobTitleFormView;
@property (strong, nonatomic) FormView *departmentFormView;
@property (strong, nonatomic) FormView *managerFormView;
@property (strong, nonatomic) FormView *officeFormView;
@property (strong, nonatomic) FormView *startDateFormView;
@property (strong, nonatomic) FormView *birthdayFormView;
@property (strong, nonatomic) UITextField *activeTextField;
@property (strong, nonatomic) FormView *selectedDateFormView;
@property (strong, nonatomic) NSArray *orderedTextFields;

@end

@implementation EditAccountViewController

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
    self.navigationItem.title = @"Edit Profile";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"SAVE" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTouched:)];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 166)];
    self.avatarImageView = [[EditAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 105, 105)];
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)];
    self.avatarImageView.userInteractionEnabled = YES;
    [self.avatarImageView addGestureRecognizer:avatarTap];
    self.avatarImageView.centerX = headerView.width/2.0;
    self.avatarImageView.centerY = headerView.height/2.0;
    [headerView addSubview:self.avatarImageView];
    self.tableView.tableHeaderView = headerView;
    
    self.firstNameFormView = [[FormView alloc] init];
    self.firstNameFormView.fieldName = @"First Name";
    
    self.lastNameFormView = [[FormView alloc] init];
    self.lastNameFormView.fieldName = @"Last Name";
    
    self.emailFormView = [[FormView alloc] init];
    self.emailFormView.fieldName = @"Email";
    
    self.workPhoneFormView = [[FormView alloc] init];
    self.workPhoneFormView.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.workPhoneFormView.textField.inputAccessoryView = [[TRKeyboardAccessoryView alloc] initWithCancel:^{
        [self.workPhoneFormView.textField resignFirstResponder];
    } doneBlock:^{
        [self.workPhoneFormView.textField resignFirstResponder];
    }];
    self.workPhoneFormView.fieldName = @"Office Phone";
    
    self.homePhoneFormView = [[FormView alloc] init];
    self.homePhoneFormView.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.homePhoneFormView.textField.inputAccessoryView = [[TRKeyboardAccessoryView alloc] initWithCancel:^{
        [self.homePhoneFormView.textField resignFirstResponder];
    } doneBlock:^{
        [self.homePhoneFormView.textField resignFirstResponder];
    }];
    self.homePhoneFormView.fieldName = @"Cell Phone";
    
    self.jobTitleFormView = [[FormView alloc] init];
    self.jobTitleFormView.fieldName = @"Title";
    
    self.departmentFormView = [[FormView alloc] init];
    self.departmentFormView.textField.userInteractionEnabled = NO;
    UITapGestureRecognizer *departmentTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(departmentCellTapped:)];
    [self.departmentFormView addGestureRecognizer:departmentTap];
    self.departmentFormView.fieldName = @"Department";
    
    self.managerFormView = [[FormView alloc] init];
    self.managerFormView.textField.userInteractionEnabled = NO;
    UITapGestureRecognizer *managerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(managerCellTapped:)];
    [self.managerFormView addGestureRecognizer:managerTap];
    self.managerFormView.fieldName = @"Reporting to";
    
    self.officeFormView = [[FormView alloc] init];
    self.officeFormView.textField.userInteractionEnabled = NO;
    UITapGestureRecognizer *officeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(officeCellTapped:)];
    [self.officeFormView addGestureRecognizer:officeTap];
    self.officeFormView.fieldName = @"Office";
    
    self.startDateFormView = [[FormView alloc] init];
    self.startDateFormView.textField.userInteractionEnabled = NO;
    UITapGestureRecognizer *startDateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startDateCellTapped:)];
    [self.startDateFormView addGestureRecognizer:startDateTap];
    self.startDateFormView.fieldName = @"Start Date";
    
    self.birthdayFormView = [[FormView alloc] init];
    self.birthdayFormView.textField.userInteractionEnabled = NO;
    UITapGestureRecognizer *birthdayTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(birthdayCellTapped:)];
    [self.birthdayFormView addGestureRecognizer:birthdayTap];
    self.birthdayFormView.fieldName = @"Birthday";
    
    for (FormView *formView in @[self.firstNameFormView, self.lastNameFormView, self.emailFormView, self.workPhoneFormView, self.homePhoneFormView, self.jobTitleFormView, self.departmentFormView, self.managerFormView, self.officeFormView, self.startDateFormView, self.birthdayFormView]) {
        formView.textField.delegate = self;
    }
    self.orderedTextFields = @[self.firstNameFormView.textField, self.lastNameFormView.textField, self.emailFormView.textField, self.workPhoneFormView.textField, self.homePhoneFormView.textField, self.jobTitleFormView.textField];
    for (UITextField *textField in self.orderedTextFields) {
        textField.returnKeyType = UIReturnKeyNext;
    }
    
    self.account = [AppDelegate sharedDelegate].store.currentAccount;
}

- (void)doneButtonTouched:(id)sender
{
    [self validateFields:^(BOOL valid, NSString *message) {
        if (valid) {
            [self saveAccount];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (void)saveAccount
{
    if (self.activeTextField) {
        [self.activeTextField resignFirstResponder];
    }
    [SVProgressHUD show];
    [self.account updateAccountWithSuccess:^(Account *account) {
        [SVProgressHUD showSuccessWithStatus:@"Profile Saved"];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    }];
}

- (void)setAccount:(Account *)account
{
    _account = account;
    [self reloadData];
}

- (void)reloadData
{
    User *user = self.account.currentUser;
    NSURL *url = [NSURL URLWithString:user.avatarUrl];
    [self.avatarImageView.imageView setImageWithURL:url];
    
    self.firstNameFormView.textField.text = user.firstName;
    self.lastNameFormView.textField.text = user.lastName;
    self.emailFormView.textField.text = user.email;
    self.workPhoneFormView.textField.text = user.employeeInfo.officePhone;
    self.homePhoneFormView.textField.text = user.employeeInfo.cellPhone;
    self.jobTitleFormView.textField.text = user.employeeInfo.jobTitle;
    Department *department = user.department;
    if (department) {
        self.departmentFormView.textField.text = department.name;
    }
    OfficeLocation *office = user.primaryOfficeLocation;
    if (office) {
        self.officeFormView.textField.text = office.name;
    }
    User *manager = user.manager;
    if (manager) {
        self.managerFormView.textField.text = manager.fullName;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (user.employeeInfo.birthDate) {
        dateFormatter.dateFormat = @"MMM d";
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        self.birthdayFormView.textField.text = [dateFormatter stringFromDate:user.employeeInfo.birthDate];
    }
    if (user.employeeInfo.jobStartDate) {
        dateFormatter.dateFormat = @"MMM d yyyy";
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        self.startDateFormView.textField.text = [dateFormatter stringFromDate:user.employeeInfo.jobStartDate];
    }
}

- (void)avatarTapped:(id)sender
{
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Edit Photo"];
    [actionSheet bk_addButtonWithTitle:@"Take Photo" handler:^{
        [self presentPhotoPickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    [actionSheet bk_addButtonWithTitle:@"Camera Roll" handler:^{
        [self presentPhotoPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [actionSheet showFromTabBar:(UITabBar *)[AppDelegate sharedDelegate].tabBarController.tabBar];
}

- (void)presentPhotoPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    [[PhotoManager sharedManager] presentImagePickerForSourceType:sourceType fromViewController:self completion:^(UIImage *image, BOOL cancelled) {
        if (image) {
            UIImage *currentImage = self.avatarImageView.imageView.image;
            self.avatarImageView.imageView.image = image;
            [SVProgressHUD show];
            [[AppDelegate sharedDelegate].store.currentAccount updateAvatarImage:image withCompletion:^(UIImage *image, NSError *error) {
                [SVProgressHUD dismiss];
                if (error) {
                    self.avatarImageView.imageView.image = currentImage;
                }
            }];
        }
    }];
}

- (void)validateFields:(void (^)(BOOL valid, NSString *message))validationBlock
{
    BOOL valid = YES;
    NSString *message;
    NSString *workPhone = self.workPhoneFormView.textField.text;
    NSString *cellPhone = self.homePhoneFormView.textField.text;
    if (!isValidPhone(cellPhone)) {
        valid = NO;
        message = @"Please enter a valid cell phone number";
    }
    if (workPhone && workPhone.length && !isValidPhone(workPhone)) {
        valid = NO;
        message = @"Please enter a valid office phone number";
    }
    if (validationBlock) {
        validationBlock(valid, message);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    if (!section) {
        numRows = 2;
    }
    else if (section == 1) {
        numRows = 3;
    }
    else if (section == 2) {
        numRows = 5;
    }
    else if (section == 3) {
        numRows = 1;
    }
    return numRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 36;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, [self tableView:tableView heightForHeaderInSection:section])];
    view.backgroundColor = [UIColor whiteColor];
    [view addEdge:UIRectEdgeBottom width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
    UILabel *label = [[UILabel alloc] init];
    label.size = CGSizeMake(view.width, 30);
    label.x = 14;
    label.bottom = view.height;
    label.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    label.font = [ThemeManager regularFontOfSize:14];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    [view addSubview:label];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, [self tableView:tableView heightForFooterInSection:section])];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *titles = @[@"NAME", @"CONTACT INFORMATION", @"YOUR POSITION", @"PERSONAL"];
    return titles[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    FormView *formView;
    if (!indexPath.section) {
        if (!indexPath.row) {
            formView = self.firstNameFormView;
        }
        else {
            formView = self.lastNameFormView;
        }
    }
    else if (indexPath.section == 1) {
        if (!indexPath.row) {
            formView = self.emailFormView;
        }
        else if (indexPath.row == 1) {
            formView = self.homePhoneFormView;
        }
        else {
            formView = self.workPhoneFormView;
        }
    }
    else if (indexPath.section == 2) {
        if (!indexPath.row) {
            formView = self.jobTitleFormView;
        }
        else if (indexPath.row == 1) {
            formView = self.departmentFormView;
        }
        else if (indexPath.row == 2) {
            formView = self.managerFormView;
        }
        else if (indexPath.row == 3) {
            formView = self.officeFormView;
        }
        else {
            formView = self.startDateFormView;
        }
    }
    else {
        formView = self.birthdayFormView;
    }
    formView.frame = cell.contentView.bounds;
    formView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:formView];
    return cell;
}

- (void)managerCellTapped:(id)sender
{
    OnboardSelectManagersViewControllers *selectManagersViewController = [[OnboardSelectManagersViewControllers alloc] init];
    selectManagersViewController.delegate = self;
    [self presentViewControllerWithNav:selectManagersViewController animated:YES completion:nil];
}

- (void)departmentCellTapped:(id)sender
{
    OnboardSelectDepartmentViewController *departmentViewController = [[OnboardSelectDepartmentViewController alloc] init];
    departmentViewController.delegate = self;
    [self presentViewControllerWithNav:departmentViewController animated:YES completion:nil];
    
}

- (void)startDateCellTapped:(id)sender
{
    if (self.activeTextField) {
        return;
    }
    DatePickerModalView *datePickerModalView = [[DatePickerModalView alloc] init];
    datePickerModalView.datePicker.dateDelegate = self;
    self.selectedDateFormView = self.startDateFormView;
    [datePickerModalView show];
}

- (void)birthdayCellTapped:(id)sender
{
    if (self.activeTextField) {
        return;
    }
    DatePickerModalView *datePickerModalView = [[DatePickerModalView alloc] init];
    datePickerModalView.datePicker.dateDelegate = self;
    datePickerModalView.hidesYear = YES;
    self.selectedDateFormView = self.birthdayFormView;
    [datePickerModalView show];
}

- (void)officeCellTapped:(id)sender
{
    OfficesViewController *officeViewController = [[OfficesViewController alloc] init];
    officeViewController.delegate = self;
    [self presentViewControllerWithNav:officeViewController animated:YES completion:nil];
}

#pragma mark - Select Department View Controller Delegate
- (void)didCancelSelectDepartmentViewController:(OnboardSelectDepartmentViewController *)selectDepartmentViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)OnboardSelectDepartmentViewController:(OnboardSelectDepartmentViewController *)selectDepartmentViewController didSelectDepartment:(Department *)department
{
    self.account.currentUser.department = department;
    [self reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Select Manager View Controller Delegate
- (void)selectManagersViewController:(OnboardSelectManagersViewControllers *)selectManagersViewController didSelectUser:(User *)user
{
    self.account.currentUser.manager = user;
    [self reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelSelectManagersViewController:(OnboardSelectManagersViewControllers *)selectManagersViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger idx = [self.orderedTextFields indexOfObject:textField];
    if (idx < self.orderedTextFields.count - 1) {
        UITextField *nextTextField = self.orderedTextFields[idx + 1];
        [nextTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
    User *user = self.account.currentUser;
    NSString *text = textField.text;
    if (textField == self.firstNameFormView.textField) {
        user.firstName = text;
    }
    else if (textField == self.lastNameFormView.textField) {
        user.lastName = text;
    }
    else if (textField == self.emailFormView.textField) {
        user.email = text;
    }
    else if (textField == self.homePhoneFormView.textField) {
        user.employeeInfo.cellPhone = text;
    }
    else if (textField == self.workPhoneFormView.textField) {
        user.employeeInfo.officePhone = text;
    }
    else if (textField == self.jobTitleFormView.textField) {
        user.employeeInfo.jobTitle = text;
    }
}

#pragma mark - data picker did select date
- (void)datePicker:(PMEDatePicker *)datePicker didSelectDate:(NSDate *)date
{
    if (self.selectedDateFormView == self.birthdayFormView) {
        self.account.currentUser.employeeInfo.birthDate = date;
    }
    else if (self.selectedDateFormView == self.startDateFormView) {
        self.account.currentUser.employeeInfo.jobStartDate = date;
    }
    [self reloadData];
}

#pragma mark - Office View Controller Delegate
- (void)didCancelOfficesViewController:(OfficesViewController *)officesViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)officesViewController:(OfficesViewController *)officesViewController didSelectOffice:(OfficeLocation *)office
{
    self.account.currentUser.primaryOfficeLocation = office;
    [self reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
