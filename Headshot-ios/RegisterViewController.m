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
    RegisterRowPhoto = 0,
    RegisterRowName,
    RegisterRowEmail,
    RegisterRowPhone
};

@interface RegisterViewController () <UITextFieldDelegate>

@property (strong, nonatomic) BAFormView *firstNameFormView;
@property (strong, nonatomic) BAFormView *lastNameFormView;
@property (strong, nonatomic) BAFormView *emailFormView;
@property (strong, nonatomic) BAFormView *phoneFormView;
@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UIButton *addPhotoButton;

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
        [self.phoneFormView.textField resignFirstResponder];
    }];;
    
    self.firstNameFormView.textField.nextControl = self.lastNameFormView.textField;
    self.lastNameFormView.textField.nextControl = self.emailFormView.textField;
    self.emailFormView.textField.nextControl = self.phoneFormView.textField;
    for (BAFormView *formView in @[self.firstNameFormView, self.lastNameFormView, self.emailFormView, self.phoneFormView]) {
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
    
    
    self.avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"onboarding-add-photo"]];
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoButtonTouched:)];
    self.avatarImageView.userInteractionEnabled = YES;
    [self.avatarImageView addGestureRecognizer:avatarTap];
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.width/2.0;
    self.addPhotoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addPhotoButton setTitle:@"Add Photo" forState:UIControlStateNormal];
    self.addPhotoButton.tintColor = [[ThemeManager sharedTheme] primaryColor];
    self.addPhotoButton.titleLabel.font = [ThemeManager lightFontOfSize:13];
    [self.addPhotoButton sizeToFit];
    [self.addPhotoButton addTarget:self action:@selector(photoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableFooterView = nil;
}

- (BAFormView *)formViewWithTitle:(NSString *)title placeHolder:(NSString *)placeholder width:(CGFloat)width
{
    BAFormView *formView = [[BAFormView alloc] initWithFrame:CGRectMake(0, 0, width, [self formViewHeight]) title:title placeholder:placeholder];
    return formView;
}

- (void)photoButtonTouched:(id)sender
{
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Add Photo"];
    [actionSheet bk_addButtonWithTitle:@"Take Photo" handler:^{
        [self presentPhotoPickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    [actionSheet bk_addButtonWithTitle:@"Camera Roll" handler:^{
        [self presentPhotoPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [actionSheet showInView:self.view];
}

- (void)presentPhotoPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    [[PhotoManager sharedManager] presentImagePickerForSourceType:sourceType fromViewController:self completion:^(UIImage *image, BOOL cancelled) {
        if (image) {
            self.avatarImageView.image = image;
        }
    }];
}

- (void)doneButtonTouched:(id)sender
{
    [self validateFields:^(BOOL valid, NSString *message) {
        if (valid) {
            [self loginWithFirstName:self.firstNameFormView.textField.text lastName:self.lastNameFormView.textField.text email:self.emailFormView.textField.text phone:self.phoneFormView.textField.text];
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

- (void)loginWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email phone:(NSString *)phone
{
    [SVProgressHUD show];
    NSDictionary *parameters = @{@"auth_params" :
                                     @{@"first_name" : firstName,
                                       @"last_name" : lastName,
                                       @"email" : email,
                                       @"phone_number" : phone}};
    [[HeadshotAPIClient sharedClient] POST:@"authentications" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [SVProgressHUD dismiss];
        AuthValidationViewController *authValidationViewController = [[AuthValidationViewController alloc] init];
        authValidationViewController.userIdentifier = responseObject[@"id"];
        [self.navigationController pushViewController:authValidationViewController animated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
    }];
}


#pragma mark - Table view data source

- (CGFloat)formViewHeight
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == RegisterRowPhoto) {
        return 105;
    }
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
    else if (indexPath.row == RegisterRowPhoto) {
        cell = [self configurePhotoCell:cell];
    }
    return cell;
}

- (UITableViewCell *)configureNameCell:(UITableViewCell *)cell
{
    [cell.contentView addSubview:self.firstNameFormView];
    [cell.contentView addSubview:self.lastNameFormView];
    self.lastNameFormView.x = self.firstNameFormView.right;
    [self.firstNameFormView addEdge:UIRectEdgeRight width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
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
    return cell;
}

- (UITableViewCell *)configurePhotoCell:(UITableViewCell *)cell
{
    [cell.contentView addSubview:self.avatarImageView];
    self.avatarImageView.centerX = cell.contentView.width/2.0;
    self.avatarImageView.y = 18;
    self.avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [cell.contentView addSubview:self.addPhotoButton];
    self.addPhotoButton.centerX = self.avatarImageView.centerX;
    self.addPhotoButton.y = self.avatarImageView.bottom;
    self.addPhotoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
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
