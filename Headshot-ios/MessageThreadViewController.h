//
//  MessageViewController.h
//  Headshot-ios
//
//  Created by Charlie White on 5/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageThread.h"
#import "Message.h"
#import <JSQMessagesViewController/JSQMessages.h>
#import <Sinch/Sinch.h>

@interface MessageThreadViewController : JSQMessagesViewController <SINMessageClientDelegate>

@property (strong, nonatomic) MessageThread *messageThread;
@property (strong, nonatomic) NSMutableArray *messages;
@property (copy, nonatomic) NSDictionary *avatars;
@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;
@property (strong, nonatomic) User *currentUser;

-(id)initWithMessageThread:(MessageThread *)messageThread;
-(void)createOrFindThreadForRecipient:(User *)recipient;


@end
