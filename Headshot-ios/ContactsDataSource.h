//
//  ContactsDataSource.h
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactsTableViewController.h"

@interface ContactsDataSource : NSObject  <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIScrollViewDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (strong, nonatomic) UITableViewController *tableViewController;

@end
