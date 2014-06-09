//
//  TRTabBarController.m
//  Triage-ios
//
//  Created by Charlie White on 1/22/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "TRTabBarController.h"
#import "TRNavigationController.h"
#import "AccountViewController.h"
#import "ContactsTableViewController.h"
#import "MessagesTableViewController.h"
#import "CredentialStore.h"
#import "RDVTabBarItem.h"
#import "LoginViewController.h"


@interface TRTabBarController ()

@end

@implementation TRTabBarController

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
    
    //self.delegate = self;
    
    // Messages
    MessagesTableViewController *messagesTableView = [[MessagesTableViewController alloc] init];
    TRNavigationController *messagesNav = [[TRNavigationController alloc] initWithRootViewController:messagesTableView];
    UIView *blockade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    blockade.backgroundColor = [UIColor whiteColor];
    [messagesNav.view addSubview:blockade];
    
    // Providers
    ContactsTableViewController *contactsTableView = [[ContactsTableViewController alloc] init];
    TRNavigationController *contactsNav = [[TRNavigationController alloc] initWithRootViewController:contactsTableView];
    
    // Settings
    AccountViewController *accountVC = [[AccountViewController alloc] init];
    TRNavigationController *accountNav = [[TRNavigationController alloc] initWithRootViewController:accountVC];
    
    
    self.tabBar.opaque = NO;
    //[self.tabBar setTintColor:[UIColor colorWithRed:165.00f green:171.00f blue:184.00f alpha:1.0f]];
    [self.tabBar setTintColor:[UIColor whiteColor]];
    [self.tabBar setBackgroundColor:[UIColor whiteColor]];
    [self  setViewControllers:[NSArray arrayWithObjects:messagesNav, contactsNav, accountNav, nil]];
    
//    
    UIImage *finishedImage = [UIImage imageNamed:@"nav_bg_on"];
    UIImage *unfinishedImage = [UIImage imageNamed:@"nav_bg_off"];
    NSArray *tabBarItemImages = @[@"messages", @"contacts", @"profile"];
    
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[self tabBar] items]) {
        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        //[item setBackgroundColor:[UIColor whiteColor]];
        
        NSLog(@"tabbar_%@_active.png",
              [tabBarItemImages objectAtIndex:index]);
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"tabbar-%@-active.png",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"tabbar-%@-inactive.png",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
    
    
    
//    [homeNav.view makeConstraints:^(MASConstraintMaker *make) {
//        //UIView *topLayoutGuide = (id)self.topLayoutGuide;
//        make.bottom.equalTo(@300);
//    }];


    [self setSelectedIndex:1];
	// Do any additional setup after loading the view.
}


-(void)viewDidAppear:(BOOL)animated
{
    // Check for authentication
    if (![[CredentialStore sharedClient] isLoggedIn]) {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self presentViewController:loginVC animated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
