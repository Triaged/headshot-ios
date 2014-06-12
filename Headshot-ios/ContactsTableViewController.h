//
//  ContactsTableViewController.h
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLSwipeNavigationController.h"

@interface ContactsTableViewController : UITableViewController <XLSwipeContainerChildItem>

@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) UIViewController *segmentController;

@end
