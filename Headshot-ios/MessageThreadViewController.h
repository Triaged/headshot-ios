//
//  MessageThreadViewController.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/3/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SLKTextViewController.h>
#import "MessageThread.h"
#import "MessageCell.h"

@interface MessageThreadViewController : SLKTextViewController


@property (strong, nonatomic) MessageThread *messageThread;

- (instancetype)initWithMessageThread:(MessageThread *)messageThread;
- (instancetype)initWithRecipients:(NSArray *)recipients;
- (id)initWithThreadID:(NSString *)threadID;

@end
