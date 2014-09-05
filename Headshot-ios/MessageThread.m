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
#import "MessageClient.h"
#import "ReadReceipt.h"

@implementation MessageThread

@dynamic name;
@dynamic lastMessageTimeStamp;
@dynamic recipients;
@dynamic messages;
@dynamic identifier;
@dynamic unread;
@dynamic muted;

+ (MessageThread *)findThreadWithRecipients:(NSSet *)recipients
{
    NSSet *threads = [AppDelegate sharedDelegate].store.currentAccount.currentUser.messageThreads;
    __block MessageThread *found;
    [threads enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        MessageThread *messageThread = (MessageThread *)obj;
        if ([messageThread.recipients isEqualToSet:recipients]) {
            found = messageThread;
           *stop = YES;
        }
    }];
    return found;
}

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

- (void)markAsRead
{
    BOOL unread = self.unread && self.unread.boolValue;
    if (unread) {
        NSArray *unreadMessages = [Message MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"messageThread = %@ AND userReadReceipt = nil", self, [AppDelegate sharedDelegate].store.currentAccount.currentUser]];
        NSDate *timestamp = [NSDate date];
        NSMutableArray *createdReceipts = [[NSMutableArray alloc] init];
        for (Message *message in unreadMessages) {
            ReadReceipt *readReceipt = [ReadReceipt MR_createEntity];
            readReceipt.message = message;
            readReceipt.timestamp = timestamp;
            [createdReceipts addObject:readReceipt];
            message.userReadReceipt = readReceipt;
        }
        [ReadReceipt postReceipts:createdReceipts withCompletion:^(NSArray *receipts, NSError *error) {
            if (!error) {
                for (ReadReceipt *receipt in receipts) {
                    receipt.acknowledged = @(YES);
                }
            }
            self.unread = @(NO);
            [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMarkedMessageThreadAsReadNotification object:nil userInfo:nil];
        }];
    }
}

- (void)updateMuted:(BOOL)muted withCompletion:(void (^)(MessageThread *thread, NSError *error))completion
{
    NSString *muteString = muted ? @"mute" : @"unmute";
    NSString *path = [NSString stringWithFormat:@"message_threads/%@/%@", self.identifier, muteString];
    [[MessageClient sharedClient].httpClient POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.muted = responseObject[@"muted"];
        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
        if (completion) {
            completion(self, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)updateName:(NSString *)name withCompletion:(void (^)(MessageThread *thread, NSError *error))completion
{
    NSString *path = [NSString stringWithFormat:@"message_threads/%@", self.identifier];
    NSDictionary *parameters = @{@"message_thread" : @{@"name" : name}};
    [[MessageClient sharedClient].httpClient PUT:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        self.name = name;
        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
        if (completion) {
            completion(self, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
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
