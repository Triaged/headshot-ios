//
//  TRTabBarController.m
//  Triage-ios
//
//  Created by Charlie White on 1/22/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "TRTabBarController.h"
#import "TRNavigationController.h"
#import "MessageNavigationController.h"
#import "AccountViewController.h"
#import "ContactsTableViewController.h"
#import "MessagesTableViewController.h"
#import "CredentialStore.h"
#import "RDVTabBarItem.h"
#import "SDCSegmentedViewController.h"
#import "DepartmentsTableViewController.h"
#import "ContactsContainerViewController.h"



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
    self.messagesTableViewController = [[MessagesTableViewController alloc] init];
    self.messageNavigationController = [[MessageNavigationController alloc] initWithRootViewController:self.messagesTableViewController];
    
    // Settings
    AccountViewController *accountVC = [[AccountViewController alloc] init];
    TRNavigationController *accountNav = [[TRNavigationController alloc] initWithRootViewController:accountVC];
    UINavigationController *contactsNav = [[TRNavigationController alloc] initWithRootViewController:[[ContactsContainerViewController alloc] init]];
    
    [self setViewControllers:[NSArray arrayWithObjects:self.messageNavigationController, contactsNav, accountNav, nil]];
    
    
    self.tabBar.translucent = NO;
    self.tabBar.tintColor = [[ThemeManager sharedTheme] orangeColor];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [[ThemeManager sharedTheme] orangeColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[[ThemeManager sharedTheme] disabledGrayTextColor], NSForegroundColorAttributeName, nil]
                                             forState:UIControlStateNormal];
    self.tabBar.backgroundColor = [UIColor whiteColor];
    
    NSArray *tabBarItemImages = @[@"messages", @"contacts", @"profile"];
    NSArray *titles = @[@"Inbox", @"Contacts", @"Profile"];
    [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImage *unselectedimage = [[UIImage imageNamed:[NSString stringWithFormat:@"tabbar-%@-active.png",
                                                      [tabBarItemImages objectAtIndex:idx]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectedimage = [[UIImage imageNamed:[NSString stringWithFormat:@"tabbar-%@-inactive.png", [tabBarItemImages objectAtIndex:idx]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:titles[idx] image:selectedimage selectedImage:unselectedimage];
        UIViewController *viewController = self.viewControllers[idx];
        viewController.tabBarItem = tabBarItem;
    }];
    
    [self setSelectedIndex:1];
	// Do any additional setup after loading the view.
}

- (void)selectMessagesViewController
{
    [self view];
    [self setSelectedIndex:0];
}

@end
