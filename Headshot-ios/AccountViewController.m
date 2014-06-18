//
//  AccountViewController.m
//  Headshot-ios
//
//  Created by Charlie White on 5/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "AccountViewController.h"
#import "EmployeeInfo.h"
#import "OfficeLocation.h"
#import "OnboardNavigationController.h"
#import "CredentialStore.h"
#import "LoginViewController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

@synthesize currentUser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    UIButton *info = [UIButton buttonWithType:UIButtonTypeInfoLight];
    info.tintColor = [[ThemeManager sharedTheme] buttonTintColor];
    [info addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:info];
    self.navigationItem.rightBarButtonItem = item;

    
    //self.title = @"Account";
    
    currentUser = [AppDelegate sharedDelegate].store.currentAccount.currentUser;
    // Do any additional setup after loading the view from its nib.
    
    NSURL *avatarUrl = [NSURL URLWithString:currentUser.avatarFaceUrl];
    [self.avatarImageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"avatar"]];
    self.nameLabel.text = currentUser.fullName;
    self.titleLabel.text = currentUser.employeeInfo.jobTitle;
    self.currentOfficeLocationLabel.text = currentUser.employeeInfo.currentOfficeLocation.streetAddress;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOnboard)];
    self.avatarImageView.userInteractionEnabled = YES;
    [self.avatarImageView addGestureRecognizer:tap
     ];
}

- (void)showOnboard
{
    [AppDelegate sharedDelegate].window.rootViewController = [[OnboardNavigationController alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)logout
{
    [[CredentialStore sharedClient] clearSavedCredentials];
    if (![[CredentialStore sharedClient] isLoggedIn]) {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self presentViewController:loginVC animated:NO completion:nil];
    }

    
}

@end
