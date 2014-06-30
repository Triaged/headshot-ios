//
//  ContactsTableViewController.h
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDCSegmentedViewController.h"

@interface ContactsTableViewController : UITableViewController <UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) SDCSegmentedViewController *segmentViewController;

@end
