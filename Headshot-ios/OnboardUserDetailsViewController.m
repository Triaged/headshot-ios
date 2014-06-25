//
//  OnboardUserDetailsViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OnboardUserDetailsViewController.h"
#import "FormView.h"
#import "DatePickerModalView.h"
#import "EmployeeInfo.h"

typedef NS_ENUM(NSUInteger, UserDetailForm)  {
    UserDetailFormFirstName = 0,
    UserDetailFormLastName,
    UserDetailFormPhone,
    UserDetailFormBirthday,
};

@interface OnboardUserDetailsViewController () <UITextFieldDelegate>

@property (strong, nonatomic) FormView *firstNameFormView;
@property (strong, nonatomic) FormView *lastNameFormView;
@property (strong, nonatomic) FormView *phoneFormView;
@property (strong, nonatomic) FormView *birthdayFormView;
@property (strong, nonatomic) FormView *passwordFormView;
@property (strong, nonatomic) UILabel *welcomeLabel;
@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) NSDate *birthday;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation OnboardUserDetailsViewController

@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUser:(User *)user
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (!self) {
        return nil;
    }
    self.user = user;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 206)];
    self.welcomeLabel = [[UILabel alloc] init];
    self.welcomeLabel.size = CGSizeMake(200, 114);
    self.welcomeLabel.centerX = headerView.width/2.0;
    self.welcomeLabel.textAlignment = NSTextAlignmentCenter;
    self.welcomeLabel.numberOfLines = 0;
    self.welcomeLabel.font = [ThemeManager regularFontOfSize:30];
    self.welcomeLabel.textColor = [[ThemeManager sharedTheme] greenColor];
    [headerView addSubview:self.welcomeLabel];
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.size = CGSizeMake(240, 56);
    descriptionLabel.y = 110;
    descriptionLabel.centerX = headerView.width/2.0;
    [headerView addSubview:descriptionLabel];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    descriptionLabel.text = @"Before you start, we would like to get to know you a bit better.";
    descriptionLabel.font = [ThemeManager regularFontOfSize:15];
    self.tableView.tableHeaderView = headerView;
    
    self.firstNameFormView = [[FormView alloc] init];
    self.firstNameFormView.textField.delegate = self;
    self.firstNameFormView.fieldName = @"First Name";
    
    self.lastNameFormView = [[FormView alloc] init];
    self.lastNameFormView.textField.delegate = self;
    self.lastNameFormView.fieldName = @"Last Name";
    
    self.phoneFormView = [[FormView alloc] init];
    self.phoneFormView.textField.delegate = self;
    self.phoneFormView.fieldName = @"Cell Number";
    self.phoneFormView.textField.placeholder = @"(100) 123-1456";
    self.phoneFormView.textField.inputAccessoryView = [[TRKeyboardAccessoryView alloc] initWithCancel:^{
        [self.phoneFormView.textField resignFirstResponder];
    } doneBlock:^{
        [self.phoneFormView.textField resignFirstResponder];
    }];
    self.phoneFormView.textField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.birthdayFormView = [[FormView alloc] init];
    self.birthdayFormView.textField.delegate = self;
    self.birthdayFormView.textField.placeholder = @"(Optional)";
    self.birthdayFormView.userInteractionEnabled = NO;
    self.birthdayFormView.fieldName = @"Birthday";
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 122)];
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextButton.size = CGSizeMake(footerView.width, 60);
    self.nextButton.bottom = footerView.height;
    self.nextButton.backgroundColor = [[ThemeManager sharedTheme] orangeColor];
    [self.nextButton setTitle:@"Continue" forState:UIControlStateNormal];
    self.nextButton.titleLabel.font = [ThemeManager regularFontOfSize:18];
    [self.nextButton addTarget:self action:@selector(nextButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:self.nextButton];
    self.tableView.tableFooterView = footerView;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"LLLL d";
}

- (void)setUser:(User *)user
{
    [self view];
    _user = user;
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome %@", user.fullName];
    self.firstNameFormView.textField.text = user.firstName;
    self.lastNameFormView.textField.text = user.lastName;
    if (user.employeeInfo.birthDate) {
        self.birthdayFormView.textField.text = [self.dateFormatter stringFromDate:user.employeeInfo.birthDate];
    }
    if (user.employeeInfo.cellPhone) {
        self.phoneFormView.textField.text = user.employeeInfo.cellPhone;
    }
}


- (void)nextButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onboardViewController:doneButtonTouched:)]) {
        [self.delegate onboardViewController:self doneButtonTouched:sender];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    FormView *formView;
    if (indexPath.row == UserDetailFormFirstName) {
        formView = self.firstNameFormView;
    }
    else if (indexPath.row == UserDetailFormLastName) {
        formView = self.lastNameFormView;
    }
    else if (indexPath.row == UserDetailFormPhone) {
        formView = self.phoneFormView;
    }
    else if (indexPath.row == UserDetailFormBirthday) {
        formView = self.birthdayFormView;
    }
    [cell.contentView addSubview:formView];
    formView.frame = cell.contentView.bounds;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == UserDetailFormBirthday) {
        DatePickerModalView *datePickerModalView = [[DatePickerModalView alloc] init];
        datePickerModalView.hidesYear = YES;
        datePickerModalView.datePicker.dateDelegate = self;
        [datePickerModalView show];
    }
}

#pragma mark - date picker
- (void)datePicker:(PMEDatePicker*)datePicker didSelectDate:(NSDate*)date {
    self.birthday = date;
    self.user.employeeInfo.birthDate = self.birthday;
    self.birthdayFormView.textField.text = [self.dateFormatter stringFromDate:self.birthday];
}


#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
