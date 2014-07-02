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
#import "SDCSegmentedViewController.h"
#import "DepartmentsTableViewController.h"



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
    
    // Settings
    AccountViewController *accountVC = [[AccountViewController alloc] init];
    TRNavigationController *accountNav = [[TRNavigationController alloc] initWithRootViewController:accountVC];
    
    if ([AppDelegate sharedDelegate].store.currentCompany.usesDepartments) {
        // Contacts
        ContactsTableViewController *contactsTableView = [[ContactsTableViewController alloc] init];
        DepartmentsTableViewController *deptsTableView = [[DepartmentsTableViewController alloc] init];
        
        SDCSegmentedViewController *segmentedController = [[SDCSegmentedViewController alloc] initWithViewControllers:@[contactsTableView, deptsTableView] titles:@[@"Contacts", @"Departments"]];
        segmentedController.segmentedControl.tintColor = [[ThemeManager sharedTheme] buttonTintColor];
        contactsTableView.segmentViewController = segmentedController;
        TRNavigationController *segmentNav = [[TRNavigationController alloc] initWithRootViewController:segmentedController];
        
        [self setViewControllers:[NSArray arrayWithObjects:messagesNav, segmentNav, accountNav, nil]];
    } else {
        ContactsTableViewController *contactsTableView = [[ContactsTableViewController alloc] init];
        TRNavigationController *contactsNav = [[TRNavigationController alloc] initWithRootViewController:contactsTableView];
        
        [self setViewControllers:[NSArray arrayWithObjects:messagesNav, contactsNav, accountNav, nil]];
    }
    
    
    self.tabBar.translucent = NO;
    self.tabBar.tintColor = [[ThemeManager sharedTheme] orangeColor];
    self.tabBar.backgroundColor = [UIColor whiteColor];
    
    
    NSArray *tabBarItemImages = @[@"messages", @"contacts", @"profile"];
    NSArray *titles = @[@"Inbox", @"Contacts", @"Profile"];
    [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"tabbar-%@-active.png",
                                                      [tabBarItemImages objectAtIndex:idx]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"tabbar-%@-inactive.png",
                                                        [tabBarItemImages objectAtIndex:idx]]];
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
