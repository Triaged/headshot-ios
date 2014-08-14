//
//  OnboardPushPermissionViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/16/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OnboardPushPermissionViewController.h"
#import "NotificationManager.h"

@interface OnboardPushPermissionViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *permissionButton;

@end

@implementation OnboardPushPermissionViewController

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
    UIImageView *messageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"onboarding-push"]];
    messageImageView.y = 67;
    messageImageView.centerX = self.view.width/2.0;
    [self.scrollView addSubview:messageImageView];
    
    UILabel *enablePushLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, messageImageView.bottom + 37, self.view.width, 31)];
    enablePushLabel.text = @"Enable Push Messages";
    enablePushLabel.font = [ThemeManager regularFontOfSize:26];
    enablePushLabel.textAlignment = NSTextAlignmentCenter;
    enablePushLabel.textColor = [[ThemeManager sharedTheme] greenColor];
    [self.scrollView addSubview:enablePushLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.size = CGSizeMake(200, 100);
    descriptionLabel.centerX = self.view.width/2.0;
    descriptionLabel.y = enablePushLabel.bottom;
    descriptionLabel.text = @"Get notified when your teammate sends you a message";
    descriptionLabel.numberOfLines = 2;
    descriptionLabel.font = [ThemeManager regularFontOfSize:15];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    [self.scrollView addSubview:descriptionLabel];
    
    self.permissionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.permissionButton.size = CGSizeMake(self.view.width, 60);
    self.permissionButton.bottom = self.scrollView.contentSize.height;
    self.permissionButton.backgroundColor = [[ThemeManager sharedTheme] orangeColor];
    self.permissionButton.titleLabel.font = [ThemeManager regularFontOfSize:18];
    [self.permissionButton setTitle:@"Grant Push Notifications" forState:UIControlStateNormal];
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
    [[NotificationManager sharedManager] registerForRemoteNotificationsWithCompletion:^(NSData *devToken, NSError *error) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsHasRequestedPushPermission];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[AnalyticsManager sharedManager] pushEnabled];
        if ([self.delegate respondsToSelector:@selector(onboardViewController:doneButtonTouched:)]) {
            [self.delegate onboardViewController:self doneButtonTouched:sender];
        }
    }];
}

@end
