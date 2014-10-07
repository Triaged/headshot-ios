//
//  NewMessageThreadViewController.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/3/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageThread.h"

@protocol MessageCellDelegate <NSObject>

- (UIFont *)fontForMessage:(Message *)message;
- (UIColor *)textColorForMessage:(Message *)message;
- (UIColor *)bubbleColorForMessage:(Message *)message;
- (UIEdgeInsets)textInsetsForMessage:(Message *)message;
- (CGFloat)maxCellWidthForMessage:(Message *)message;

@end

@interface NewMessageThreadViewController : UITableViewController <MessageCellDelegate>


@property (strong, nonatomic) MessageThread *messageThread;

- (instancetype)initWithMessageThread:(MessageThread *)messageThread;

@end
