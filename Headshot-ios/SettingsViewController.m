//
//  SettingsViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/22/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "SettingsViewController.h"
#import "EditAccountViewController.h"
#import "ChangePasswordViewController.h"
#import "LocationClient.h"
#import "User.h"
#import <MFMailComposeViewController+BlocksKit.h>

typedef NS_ENUM(NSUInteger, SettingsSection)  {
    SettingsSectionAccount,
    SettingsSectionLocation,
    SettingsSectionMore,
};

@interface SettingsViewController ()

@property (strong, nonatomic) UISwitch *locationSwitch;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Settings";
    
    self.locationSwitch = [[UISwitch alloc] init];
    self.locationSwitch.onTintColor = [[ThemeManager sharedTheme] greenColor];
    self.locationSwitch.on = [AppDelegate sharedDelegate].store.currentAccount.currentUser.sharingOfficeLocation.boolValue;
    [self.locationSwitch addTarget:self action:@selector(locationSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)locationSwitchValueChanged:(UISwitch *)sender
{
    BOOL sharingLocation = self.locationSwitch.on;
    Account *account = [AppDelegate sharedDelegate].store.currentAccount;
    account.currentUser.sharingOfficeLocation = @(sharingLocation);
    [SVProgressHUD show];
    [account updateAccountWithSuccess:^(Account *account) {
        [SVProgressHUD dismiss];
        if (sharingLocation) {
            [[LocationClient sharedClient] startMonitoringOffices];
        }
        else {
            [[LocationClient sharedClient] stopMonitoringOffices];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 2;
    if (section == SettingsSectionLocation) {
        numRows = 1;
    }
    return numRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    if (!section) {
        title = @"Account";
    }
    else if (section == 1) {
        title = @"Location";
    }
    else {
        title = @"More";
    }
    return title;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, [self tableView:tableView heightForHeaderInSection:section])];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.size = CGSizeMake(view.width, 30);
    titleLabel.bottom = view.height;
    titleLabel.x = 15;
    titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    titleLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    titleLabel.font = [ThemeManager regularFontOfSize:14];
    [view addSubview:titleLabel];
    
    [view addEdge:UIRectEdgeBottom width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 0.5)];
    [footerView addEdge:UIRectEdgeBottom width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
    return footerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.font = [ThemeManager regularFontOfSize:16];
    cell.textLabel.textColor = [[ThemeManager sharedTheme] darkGrayTextColor];
    cell.detailTextLabel.font = [ThemeManager regularFontOfSize:10];
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    
    NSString *title;
    NSString *subtitle;
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UIView *accessoryView;
    if (indexPath.section == SettingsSectionAccount) {
        if (!indexPath.row) {
            title = @"Edit your profile";
        }
        else if (indexPath.row == 1) {
            title = @"Change Password";
        }
    }
    else if (indexPath.section == SettingsSectionLocation) {
        title = @"Enable Office Availability";
        subtitle = @"Let coworkers know when you are in the office";
        accessoryView = self.locationSwitch;
    }
    else if (indexPath.section == SettingsSectionMore) {
        if (!indexPath.row) {
            title = @"Feedback";
        }
        else if (indexPath.row == 1) {
            accessoryType = UITableViewCellAccessoryNone;
            title = @"Logout";
        }
    }
    if (accessoryView) {
        cell.accessoryView = accessoryView;
    }
    else {
        cell.accessoryType = accessoryType;
    }
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == SettingsSectionAccount) {
        if (!indexPath.row) {
            [self editProfile];
        }
        else if (indexPath.row == 1) {
            [self changePassword];
        }
    }
    else if (indexPath.section == SettingsSectionMore) {
        if (!indexPath.row) {
            [self feedbackSelected];
        }
        else {
            [self logoutSelected];
        }
    }
}

- (void)feedbackSelected
{
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    [mailViewController setSubject:NSLocalizedString(@"Hi Badge Team!", @"")];
    [mailViewController setToRecipients:@[@"team@badge.co"]];
    [mailViewController bk_setCompletionBlock:^(MFMailComposeViewController *mailComposeViewController, MFMailComposeResult result, NSError *error) {
        [mailComposeViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    [[AppDelegate sharedDelegate].window.rootViewController presentViewController:mailViewController animated:YES completion:nil];
}

- (void)logoutSelected
{
    [[AppDelegate sharedDelegate] logout];
}

- (void)changePassword
{
    ChangePasswordViewController *changePasswordViewController = [[ChangePasswordViewController alloc] init];
    [self.navigationController pushViewController:changePasswordViewController animated:YES];
}

- (void)editProfile
{
    EditAccountViewController *editProfileViewController = [[EditAccountViewController alloc] init];
    [self.navigationController pushViewController:editProfileViewController animated:YES];
}


@end
