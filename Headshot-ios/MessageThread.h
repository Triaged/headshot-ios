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

@property (readonly) Message *lastMessage;
@property (nonatomic, retain) NSDate * lastMessageTimeStamp;
@property (nonatomic, retain) NSSet *recipients;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSString *identifier;

@end

@interface MessageThread (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(NSManagedObject *)value;
- (void)removeMessagesObject:(NSManagedObject *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;
- (void)addRecipients:(NSSet *)values;
- (void)removeRecipients:(NSSet *)values;

@end
