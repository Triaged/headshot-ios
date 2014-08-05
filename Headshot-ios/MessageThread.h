//
//  MessageThread.h
//  Headshot-ios
//
//  Created by Charlie White on 5/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User, Message;

@interface MessageThread : NSManagedObject

@property (nonatomic, retain) NSDate * lastMessageTimeStamp;
@property (nonatomic, retain) NSSet *recipients;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSNumber *unread;

@property (nonatomic, readonly) Message *lastMessage;
@property (nonatomic, readonly) BOOL isGroupThread;
@property (nonatomic, readonly) NSSet *recipientsExcludeUser;

/**
 Recipient of a direct message with the current user. If the thread is a group message thread this is nil.
 */
@property (nonatomic, readonly) User *directMessageRecipient;
@property (nonatomic, readonly) NSString *defaultTitle;

+ (MessageThread *)findThreadWithRecipients:(NSSet *)recipients;

- (void)markAsRead;

@end

@interface MessageThread (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(NSManagedObject *)value;
- (void)removeMessagesObject:(NSManagedObject *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;
- (void)addRecipients:(NSSet *)values;
- (void)removeRecipients:(NSSet *)values;

@end
