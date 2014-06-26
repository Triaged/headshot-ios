//
//  TRNavigationViewController.m
//  Triage-ios
//
//  Created by Charlie White on 11/5/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import "TRNavigationController.h"
#import "UIProgressView+AFNetworking.h"

@interface TRNavigationController ()

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
    
	// Do any additional setup after loading the view.
//    for (UIView *view in self.navigationBar.subviews) {
//        for (UIView *view2 in view.subviews) {
//            if ([view2 isKindOfClass:[UIImageView class]]) {
//                [view2 removeFromSuperview];
//            }
//        }
//    }
    
    //self.navigationBar.layer.opacity = 0.0;
    self.navigationBar.shadowImage = nil;
    
    self.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationBar.translucent = NO;
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}



-(void)popToRoot{
    [self popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
