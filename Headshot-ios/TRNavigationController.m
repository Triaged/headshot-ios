//
//  TRNavigationViewController.m
//  Triage-ios
//
//  Created by Charlie White on 11/5/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import "TRNavigationController.h"
#import "UIProgressView+AFNetworking.h"

@interface TRNavigationController () <UINavigationBarDelegate>

@end

@implementation TRNavigationController

@synthesize progress;

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
    self.delegate = self;
    self.navigationBar.shadowImage = nil;
    
    self.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationBar.translucent = NO;
    
}

-(void)popToRoot{
    [self popToRootViewControllerAnimated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item
{
    navigationBar.backItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    return YES;
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item
{
    navigationBar.backItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end
