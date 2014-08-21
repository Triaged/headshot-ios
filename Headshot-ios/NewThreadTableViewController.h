//
//  NewThreadTableViewController.h
//  Headshot-ios
//
//  Created by Charlie White on 5/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "MessagesTableViewController.h"

@class NewThreadTableViewController;
@protocol NewThreadTableViewControllerDelegate <NSObject>

- (void)newThreadTableViewController:(NewThreadTableViewController *)newThreadTableViewController didSelectUsers:(NSArray *)users;

@end

@interface NewThreadTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (weak, nonatomic) id<NewThreadTableViewControllerDelegate>delegate;
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) BOOL addMemberMode;
@property (strong, nonatomic) NSSet *unselectableUsers;

@end
