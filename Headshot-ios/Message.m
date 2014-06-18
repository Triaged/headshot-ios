//
//  Message.m
//  Headshot-ios
//
//  Created by Charlie White on 5/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "Message.h"
#import "MessageThread.h"
#import "User.h"


@implementation Message

@dynamic messageID;
@dynamic messageText;
@dynamic timestamp;
@dynamic messageThread;
@dynamic author;


/**
 *  @return The body text of the message.
 *  @warning You must not return `nil` from this method.
 */
- (NSString *)text {
    return self.messageText;
}

/**
 *  @return The name of the user who sent the message.
 *  @warning You must not return `nil` from this method.
 */
- (NSString *)sender {
    return self.author.fullName;
}

/**
 *  @return The date that the message was sent.
 *  @warning You must not return `nil` from this method.
 */
- (NSDate *)date {
    return self.timestamp;
}

@end
