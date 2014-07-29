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

- (NSSet *)recipientsExcludeUser
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier != %@", [AppDelegate sharedDelegate].store.currentAccount.identifier];
    return [self.recipients filteredSetUsingPredicate:predicate];
}

- (BOOL)isGroupThread
{
    return self.recipients && self.recipients.count > 2;
}

- (User *)directMessageRecipient
{
    return self.isGroupThread ? nil : [self.recipientsExcludeUser anyObject];
}

- (NSString *)defaultTitle
{
    NSString *title;
    if (self.isGroupThread) {
        NSArray *recipients = self.recipientsExcludeUser.allObjects;
        User *first = [recipients firstObject];
        title = first.firstName;
        for (NSInteger i=1; i < recipients.count - 1; i++) {
            NSString *name = [recipients[i] firstName];
            title = [NSString stringWithFormat:@"%@, %@", title, name];
        }
        User *last = [recipients lastObject];
        title = [NSString stringWithFormat:@"%@ & %@", title, last.firstName];
    }
    else {
        title = self.directMessageRecipient.fullName;
    }
    return title;
}

@end
