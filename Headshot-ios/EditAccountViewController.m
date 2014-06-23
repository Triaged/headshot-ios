    //
//  EditProfileViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/22/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "EditAccountViewController.h"
#import "HeadshotRequestAPIClient.h"
#import "EditAvatarImageView.h"
#import "FormView.h"
#import "PhotoManager.h"
#import "User.h"
#import "Department.h"
#import "OfficeLocation.h"
#import "EmployeeInfo.h"

@interface EditAccountViewController () <UITextFieldDelegate>

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
    self.workPhoneFormView.fieldName = @"Office Phone";
    
    self.homePhoneFormView = [[FormView alloc] init];
    self.homePhoneFormView.fieldName = @"Cell Phone";
    
    self.jobTitleFormView = [[FormView alloc] init];
    self.jobTitleFormView.fieldName = @"Title";
    
    self.departmentFormView = [[FormView alloc] init];
    self.departmentFormView.fieldName = @"Department";
    
    self.managerFormView = [[FormView alloc] init];
    self.managerFormView.fieldName = @"Reporting to";
    
    self.officeFormView = [[FormView alloc] init];
    self.officeFormView.fieldName = @"Office";
    
    self.startDateFormView = [[FormView alloc] init];
    self.startDateFormView.fieldName = @"Start Date";
    
    self.birthdayFormView = [[FormView alloc] init];
    self.birthdayFormView.fieldName = @"Birthday";
    
    for (FormView *formView in @[self.firstNameFormView, self.lastNameFormView, self.emailFormView, self.workPhoneFormView, self.homePhoneFormView, self.jobTitleFormView, self.departmentFormView, self.managerFormView, self.officeFormView, self.startDateFormView, self.birthdayFormView]) {
        formView.textField.delegate = self;
    }
    
    self.account = [AppDelegate sharedDelegate].store.currentAccount;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[AppDelegate sharedDelegate].tabBarController setTabBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[AppDelegate sharedDelegate].tabBarController setTabBarHidden:NO animated:NO];
}

- (void)setAccount:(Account *)account
{
    _account = account;
    User *user = account.currentUser;
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
    [actionSheet showInView:self.tableView];
}

- (void)presentPhotoPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    [[PhotoManager sharedManager] presentImagePickerForSourceType:sourceType fromViewController:self completion:^(UIImage *image, BOOL cancelled) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
        NSDictionary *parameters = @{@"user" : @{@"avatar" : imageData}};
        NSString *imageName = @"name";
        [[HeadshotRequestAPIClient sharedClient] POST:@"account/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData name:@"image" fileName:[imageName stringByAppendingString:@".jpg"] mimeType:@"image/jpg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }];
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
    CGFloat height = !section ? 30 : 66;
    return height;
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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
