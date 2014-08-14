//
//  OnboardNavigationController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OnboardNavigationController.h"
#import "EmailLoginViewController.h"
#import "OnboardUserDetailsViewController.h"
#import "OnboardAddPhotoViewController.h"
#import "OnboardJobViewController.h"
#import "OnboardSelectOfficeViewController.h"
#import "OnboardLocationPermissionViewController.h"
#import "OnboardPushPermissionViewController.h"
#import "ForgotPasswordViewController.h"
#import "AppDelegate.h"
#import "Store.h"
#import "Account.h"

@interface OnboardNavigationController () <UINavigationControllerDelegate>

@property (assign, nonatomic) BOOL waitingToShowNextViewController;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) EmailLoginViewController *loginViewController;
@property (strong, nonatomic) OnboardUserDetailsViewController *userDetailsViewController;
@property (strong, nonatomic) OnboardAddPhotoViewController *addPhotoViewController;
@property (strong, nonatomic) OnboardJobViewController *jobViewController;
@property (strong, nonatomic) OnboardSelectOfficeViewController *selectOfficeViewController;
@property (strong, nonatomic) OnboardLocationPermissionViewController *locationPermissionsViewController;
@property (strong, nonatomic) OnboardPushPermissionViewController *pushPermissionsViewController;

@end

@implementation OnboardNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    self.delegate = self;
    self.loginViewController = [[EmailLoginViewController alloc] init];
    self.loginViewController.delegate = self;
    
    self.addPhotoViewController = [[OnboardAddPhotoViewController alloc] init];
    self.addPhotoViewController.delegate = self;
    
    
    self.jobViewController = [[OnboardJobViewController alloc] init];
    self.jobViewController.delegate = self;
    
    self.selectOfficeViewController = [[OnboardSelectOfficeViewController alloc] init];
    self.selectOfficeViewController.delegate = self;
    
    self.locationPermissionsViewController = [[OnboardLocationPermissionViewController alloc] init];
    self.locationPermissionsViewController.delegate = self;
    
    self.pushPermissionsViewController = [[OnboardPushPermissionViewController alloc] init];
    self.pushPermissionsViewController.delegate = self;
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.size = CGSizeMake(100, self.navigationBar.height);
    self.pageControl.centerX = self.navigationBar.width/2.0;
    self.pageControl.numberOfPages = 4;
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.currentPageIndicatorTintColor = [[ThemeManager sharedTheme] greenColor];
    [self.navigationBar addSubview:self.pageControl];
    
    self.viewControllers = @[self.loginViewController];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsLoggedIn]) {
        [self pushViewController:self.userDetailsViewController animated:NO];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasStoredCompany) name:kHasStoredCompanyNotification object:nil];
}

- (OnboardUserDetailsViewController *)userDetailsViewController
{
    if (!_userDetailsViewController) {
        _userDetailsViewController = [[OnboardUserDetailsViewController alloc] initWithUser:[AppDelegate sharedDelegate].store.currentAccount.currentUser];
        _userDetailsViewController.delegate = self;
    }
    return _userDetailsViewController;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)hasStoredCompany
{
    if (self.waitingToShowNextViewController) {
        [SVProgressHUD dismiss];
        [self showNextViewController:self.topViewController];
        self.waitingToShowNextViewController = NO;
    }
}

#pragma mark - Onboard View Controller delegate
- (void)onboardViewController:(UIViewController *)viewController doneButtonTouched:(id)sender
{
    [self showNextViewController:viewController];
}

- (void)onboardViewController:(UIViewController<OnboardViewController> *)viewController skipButtonTouched:(id)sender
{
    [self showNextViewController:viewController];
}

- (void)showNextViewController:(UIViewController *)previousViewController
{
    UIViewController *nextViewController;
    if (previousViewController == self.loginViewController) {
        nextViewController = self.userDetailsViewController;
    }
    else if (previousViewController == self.userDetailsViewController) {
        if (![AppDelegate sharedDelegate].store.hasStoredCompany) {
            self.waitingToShowNextViewController = YES;
            [SVProgressHUD show];
            return;
        }
        nextViewController = self.addPhotoViewController;
    }
    else if (previousViewController == self.addPhotoViewController) {
        nextViewController = self.jobViewController;
    }
    else if (previousViewController == self.jobViewController) {
        nextViewController = self.selectOfficeViewController;
    }
    else if (previousViewController == self.selectOfficeViewController) {
        [[AppDelegate sharedDelegate].store.currentAccount updateAccountWithSuccess:^(Account *account) {
            
        } failure:nil];
        nextViewController = self.locationPermissionsViewController;
    }
    else if (previousViewController == self.locationPermissionsViewController) {
        nextViewController = self.pushPermissionsViewController;
    }
    if (nextViewController && nextViewController != self.topViewController) {
        [self pushViewController:nextViewController animated:YES];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsHasFinishedOnboarding];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [AppDelegate sharedDelegate].window.rootViewController = [AppDelegate sharedDelegate].tabBarController;
        [[AppDelegate sharedDelegate].tabBarController setSelectedIndex:1];
    }
}

#pragma mark - Navigation Controller Delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self.loginViewController) {
        [self setNavigationBarHidden:YES animated:YES];
    }
    else {
        [self setNavigationBarHidden:NO animated:YES];
    }
    NSInteger vcCount = navigationController.viewControllers.count;
    BOOL showPageControl = vcCount > 1 && vcCount <= 5 && ![viewController isKindOfClass:[ForgotPasswordViewController class]];
    self.pageControl.hidden = !showPageControl;
    if (showPageControl) {
        self.pageControl.currentPage = vcCount - 2;
    }
    
    if (vcCount >= 2) {
        UIViewController *previous = navigationController.viewControllers[navigationController.viewControllers.count - 2];
        previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}


@end
