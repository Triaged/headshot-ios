//
//  OnboardLocationPermissionViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/16/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OnboardLocationPermissionViewController.h"

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
    self.scrollView.contentSize = CGSizeMake(self.view.width, 524);
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    UIImageView *locationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"onboarding-location"]];
    locationImageView.y = 67;
    locationImageView.centerX = self.view.width/2.0;
    [self.scrollView addSubview:locationImageView];
    
    self.permissionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.permissionButton.size = CGSizeMake(self.view.width, 60);
    self.permissionButton.bottom = self.scrollView.contentSize.height;
    self.permissionButton.backgroundColor = [[ThemeManager sharedTheme] orangeColor];
    self.permissionButton.titleLabel.font = [ThemeManager regularFontOfSize:18];
    [self.permissionButton setTitle:@"Grant Location Permission" forState:UIControlStateNormal];
    [self.permissionButton addTarget:self action:@selector(permissionButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.permissionButton];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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

@end
