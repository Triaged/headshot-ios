//
//  NewMessageThreadViewController.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/3/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageThread.h"
#import "MessageCell.h"

@interface NewMessageThreadViewController : UITableViewController <MessageCellDelegate>


@property (strong, nonatomic) MessageThread *messageThread;

- (instancetype)initWithMessageThread:(MessageThread *)messageThread;

@end
