//
//  GroupMessageInfoTableViewController.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/30/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GroupMessageInfoTableViewController;
@protocol GroupMessageInfoTableViewController <NSObject>

- (void)groupMessageInfoTableViewController:(GroupMessageInfoTableViewController *)groupMessageInfoViewController didSelectUser:(User *)user;

@end

@interface GroupMessageInfoTableViewController : UITableViewController

@property (weak, nonatomic) id<GroupMessageInfoTableViewController> delegate;
@property (strong, nonatomic) NSArray *users;

- (id)initWithUsers:(NSArray *)users;

@end
