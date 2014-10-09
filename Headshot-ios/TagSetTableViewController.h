//
//  TagSetTableViewController.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/8/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagSet.h"
#import "TagSetItem.h"

@class TagSetTableViewController;
@protocol TagSetTableViewControllerDelegate <NSObject>

- (void)tagSetTableViewController:(TagSetTableViewController *)tagSetTableViewController didSelectTagSetItem:(TagSetItem *)tagSetItem;

@end

@interface TagSetTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *previousTagSetItems;
@property (strong, nonatomic) TagSet *tagSet;
@property (weak, nonatomic) id<TagSetTableViewControllerDelegate> delegate;

- (void)reloadData;

@end
