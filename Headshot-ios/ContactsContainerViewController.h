//
//  ContactsContainerViewController.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/16/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContactsTableViewController, DepartmentsTableViewController;
@interface ContactsContainerViewController : UITableViewController

@property (strong, nonatomic) ContactsTableViewController *contactsViewController;
@property (strong, nonatomic) DepartmentsTableViewController *departmentsViewController;
@property (assign, nonatomic) BOOL departmentsHidden;

@end
