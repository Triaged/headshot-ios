//
//  MessagesTableViewController.h
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface MessagesTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIScrollViewDelegate>


@property (strong, nonatomic) NSArray *messageThreads;

-(void)createOrFindThreadForRecipient:(User *)recipient;


@end
