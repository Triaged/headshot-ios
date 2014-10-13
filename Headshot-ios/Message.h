//
//  Message.h
//  Headshot-ios
//
//  Created by Charlie White on 5/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <JSQMessagesViewController/JSQMessages.h>

@class MessageThread, User, ReadReceipt;

@interface Message : NSManagedObject <JSQMessageData>

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSNumber * failed;
@property (nonatomic, retain) NSString * messageID;
@property (nonatomic, retain) NSString * messageText;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) ReadReceipt *userReadReceipt;
@property (nonatomic, retain) NSSet *readReceipts;
@property (nonatomic, retain) MessageThread *messageThread;
@property (nonatomic, retain) User *author;

@property (nonatomic, readonly) NSSet *readRecieptsExcludeAuthor;

@end
