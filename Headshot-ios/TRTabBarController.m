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
    UIView *blockade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    blockade.backgroundColor = [UIColor whiteColor];
    [messagesNav.view addSubview:blockade];
    
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
    
    
    self.tabBar.opaque = NO;
    //[self.tabBar setTintColor:[UIColor whiteColor]];
    //[self.tabBar setBackgroundColor:[UIColor whiteColor]];
    
    

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
    
    [self setSelectedIndex:1];
	// Do any additional setup after loading the view.
}

- (void)selectMessagesViewController
{
    [self view];
    [self setSelectedIndex:0];
}

@end
