//
//  ContactsDataSource.h
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactsTableViewController.h"
#import "User.h"

@interface ContactsDataSource : NSObject  <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIScrollViewDelegate, UISearchDisplayDelegate>


@property (strong, nonatomic) UITableViewController *tableViewController;
@property (strong, nonatomic) NSArray *users;
@property (assign, nonatomic) BOOL separateSectionsForNames;

- (id)initWithUsers:(NSArray *)users;
- (User *)userAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)usersInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (void)endSearch;

@end
