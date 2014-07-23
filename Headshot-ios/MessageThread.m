//
//  MessageThread.m
//  Headshot-ios
//
//  Created by Charlie White on 5/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "MessageThread.h"
#import "User.h"
#import "Message.h"

@implementation MessageThread

@dynamic lastMessageTimeStamp;
@dynamic recipients;
@dynamic messages;
@dynamic identifier;

- (Message *)lastMessage
{
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    NSArray *sortedMessages = [self.messages sortedArrayUsingDescriptors:@[timeSort]];
    return [sortedMessages firstObject];
}

@end
