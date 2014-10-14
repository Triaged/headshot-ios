//
//  UserProfileViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/14/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "UserProfileViewController.h"
#import "SettingsViewController.h"

@implementation UserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_settings"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.user = [User currentUser];
    [super viewWillAppear:animated];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return NO;
}

-(void)showSettings
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}


@end
