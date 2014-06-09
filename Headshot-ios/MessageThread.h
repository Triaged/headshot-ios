//
//  MessageThread.h
//  Headshot-ios
//
//  Created by Charlie White on 5/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface MessageThread : NSManagedObject

@property (nonatomic, retain) NSDate * lastMessageTimeStamp;
@property (nonatomic, retain) User *recipient;
@property (nonatomic, retain) NSSet *messages;
@end

@interface MessageThread (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(NSManagedObject *)value;
- (void)removeMessagesObject:(NSManagedObject *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
