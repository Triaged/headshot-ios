//
//  OnboardLocationPermissionViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/16/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OnboardLocationPermissionViewController.h"
#import "LocationClient.h"

@interface OnboardLocationPermissionViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *permissionButton;
@end

@implementation OnboardLocationPermissionViewController

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStylePlain target:self action:@selector(skipButtonTouched:)];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.contentSize = CGSizeMake(self.view.width, 504);
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    UIImageView *locationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"onboarding-location"]];
    locationImageView.y = 67;
    locationImageView.centerX = self.view.width/2.0;
    [self.scrollView addSubview:locationImageView];
    
    UILabel *wellDoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, locationImageView.bottom + 37, self.view.width, 31)];
    wellDoneLabel.text = @"Well Done!";
    wellDoneLabel.font = [ThemeManager regularFontOfSize:26];
    wellDoneLabel.textAlignment = NSTextAlignmentCenter;
    wellDoneLabel.textColor = [[ThemeManager sharedTheme] greenColor];
    [self.scrollView addSubview:wellDoneLabel];
    
    UILabel *allSetLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, wellDoneLabel.bottom, self.view.width, 45)];
    allSetLabel.text = @"You are all set up. Just two last steps...";
    allSetLabel.font = [ThemeManager regularFontOfSize:15];
    allSetLabel.textAlignment = NSTextAlignmentCenter;
    allSetLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    [self.scrollView addSubview:allSetLabel];
    
    UILabel *allowTrackingLabel = [[UILabel alloc] init];
    allowTrackingLabel.size = CGSizeMake(260, 70);
    allowTrackingLabel.centerX = self.view.width/2.0;
    allowTrackingLabel.y = allSetLabel.bottom + 30;
    allowTrackingLabel.text = @"Allow location services to let your team know when you are at your office. We are going to track only your office location";
    allowTrackingLabel.textAlignment = NSTextAlignmentCenter;
    allowTrackingLabel.numberOfLines = 3;
    allowTrackingLabel.font = [ThemeManager regularFontOfSize:15];
    allowTrackingLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    [self.scrollView addSubview:allowTrackingLabel];
    
    self.permissionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.permissionButton.size = CGSizeMake(self.view.width, 60);
    self.permissionButton.bottom = self.scrollView.contentSize.height;
    self.permissionButton.backgroundColor = [[ThemeManager sharedTheme] orangeColor];
    self.permissionButton.titleLabel.font = [ThemeManager regularFontOfSize:18];
    [self.permissionButton setTitle:@"Grant Location Permission" forState:UIControlStateNormal];
    [self.permissionButton addTarget:self action:@selector(permissionButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.permissionButton];
}

- (void)skipButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onboardViewController:doneButtonTouched:)]) {
        [self.delegate onboardViewController:self doneButtonTouched:sender];
    }
}

- (void)permissionButtonTouched:(id)sender
{
    [[LocationClient sharedClient] requestLocationPermissions:^(CLAuthorizationStatus authorizationStatus) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsHasRequestedLocationPermission];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if ([self.delegate respondsToSelector:@selector(onboardViewController:doneButtonTouched:)]) {
            [self.delegate onboardViewController:self doneButtonTouched:sender];
        }
    }];
}

@end
