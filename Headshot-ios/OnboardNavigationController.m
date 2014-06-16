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
#import "OnboardJobViewController.h"
#import "OnboardSelectOfficeViewController.h"
#import "AppDelegate.h"
#import "Store.h"
#import "Account.h"

@interface OnboardNavigationController () <UINavigationControllerDelegate>

@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) EmailLoginViewController *loginViewController;
@property (strong, nonatomic) OnboardUserDetailsViewController *userDetailsViewController;
@property (strong, nonatomic) OnboardJobViewController *jobViewController;
@property (strong, nonatomic) OnboardSelectOfficeViewController *selectOfficeViewController;

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
    self.viewControllers = @[self.loginViewController];
    
    self.userDetailsViewController = [[OnboardUserDetailsViewController alloc] initWithUser:[AppDelegate sharedDelegate].store.currentAccount.currentUser];
    self.userDetailsViewController.delegate = self;
    
    self.jobViewController = [[OnboardJobViewController alloc] init];
    self.jobViewController.delegate = self;
    
    self.selectOfficeViewController = [[OnboardSelectOfficeViewController alloc] init];
    self.selectOfficeViewController.delegate = self;
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.size = CGSizeMake(100, self.navigationBar.height);
    self.pageControl.centerX = self.navigationBar.width/2.0;
    self.pageControl.numberOfPages = 3;
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.currentPageIndicatorTintColor = [[ThemeManager sharedTheme] greenColor];
    [self.navigationBar addSubview:self.pageControl];
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Onboard View Controller delegate
- (void)onboardViewController:(UIViewController *)viewController doneButtonTouched:(id)sender
{
    UIViewController *nextViewController;
    if (viewController == self.loginViewController) {
        nextViewController = self.userDetailsViewController;
    }
    else if (viewController == self.userDetailsViewController) {
        nextViewController = self.jobViewController;
    }
    else if (viewController == self.jobViewController) {
        nextViewController = self.selectOfficeViewController;
    }
    [self pushViewController:nextViewController animated:YES];
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
//    viewController.navigationItem.titleView = self.pageControl;
    self.pageControl.currentPage = navigationController.viewControllers.count;
    if (navigationController.viewControllers.count < 2) {
        return;
    }
    UIViewController *previous = navigationController.viewControllers[navigationController.viewControllers.count - 2];
    previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}


@end
