//
//  ContactsContainerViewController.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/16/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagSet.h"

@class ContactsTableViewController, DepartmentsTableViewController, TagSetTableViewController;
@interface ContactsContainerViewController : UITableViewController

@property (strong, nonatomic) ContactsTableViewController *contactsViewController;
@property (strong, nonatomic) TagSetTableViewController *departmentsViewController;
@property (assign, nonatomic) BOOL tagsHidden;
@property (strong, nonatomic) NSArray *users;

@end
