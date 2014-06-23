//
//  SettingsViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/22/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "SettingsViewController.h"
#import "EditProfileViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Settings";
}

-(void)viewWillAppear:(BOOL)animated {
    [[AppDelegate sharedDelegate].tabBarController setTabBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[AppDelegate sharedDelegate].tabBarController setTabBarHidden:NO animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    if (!section) {
        title = @"Account";
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
    return [[UIView alloc] init];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.font = [ThemeManager regularFontOfSize:16];
    cell.textLabel.textColor = [[ThemeManager sharedTheme] darkGrayTextColor];
    
    NSString *title;
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (!indexPath.section) {
        if (!indexPath.row) {
            title = @"Edit your profile";
        }
        else if (indexPath.row == 1) {
            title = @"Change Password";
        }
    }
    else if (indexPath.section == 1) {
        if (!indexPath.row) {
            title = @"About";
        }
        else if (indexPath.row == 1) {
            accessoryType = UITableViewCellAccessoryNone;
            title = @"Logout";
        }
    }
    cell.accessoryType = accessoryType;
    cell.textLabel.text = title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!indexPath.section) {
        if (!indexPath.row) {
            [self editProfile];
        }
    }
}

- (void)editProfile
{
    EditProfileViewController *editProfileViewController = [[EditProfileViewController alloc] init];
    [self.navigationController pushViewController:editProfileViewController animated:YES];
}


@end
