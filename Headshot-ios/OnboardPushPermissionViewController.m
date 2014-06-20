//
//  OnboardPushPermissionViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/16/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OnboardPushPermissionViewController.h"

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
    self.scrollView.contentSize = CGSizeMake(self.view.width, 524);
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    UIImageView *locationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"onboarding-push"]];
    locationImageView.y = 67;
    locationImageView.centerX = self.view.width/2.0;
    [self.scrollView addSubview:locationImageView];
    
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
    if ([self.delegate respondsToSelector:@selector(onboardViewController:doneButtonTouched:)]) {
        [self.delegate onboardViewController:self doneButtonTouched:sender];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
