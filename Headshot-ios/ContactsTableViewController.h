//
//  ContactsTableViewController.h
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@class ContactsTableViewController;
@protocol ContactsTableViewControllerDelegate <NSObject>

- (void)contactsTableViewController:(ContactsTableViewController *)contactsTableViewController didSelectContact:(User *)user;

@end
@class ContactsContainerViewController;
@interface ContactsTableViewController : UITableViewController <UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, weak)  ContactsContainerViewController *containerViewController;
@property (nonatomic, weak) id<ContactsTableViewControllerDelegate> contactsTableViewControllerDelegate;
@property (strong, nonatomic) NSSet *tagSetItems;

@end
