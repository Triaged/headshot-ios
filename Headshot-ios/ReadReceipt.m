//
//  ReadReceipt.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 9/3/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "ReadReceipt.h"
#import "Message.h"
#import "MessageThread.h"
#import "User.h"
#import "MessageClient.h"


@implementation ReadReceipt

@dynamic timestamp;
@dynamic acknowledged;
@dynamic message;
@dynamic user;

+ (void)postReceipts:(NSArray *)receipts withCompletion:(void (^)(NSArray *receipts, NSError *error))completion
{
    NSMutableArray *receiptJSON = [[NSMutableArray alloc] init];
    for (ReadReceipt *receipt in receipts) {
        NSDictionary *jsonValue = @{@"thread_id" : receipt.message.messageThread.identifier, @"message_id" : receipt.message.messageID, @"user_id" : [AppDelegate sharedDelegate].store.currentAccount.currentUser.identifier, @"timestamp" : @(receipt.timestamp.timeIntervalSince1970)};
        [receiptJSON addObject:jsonValue];
    }
    NSDictionary *parameters = @{@"receipts" : receiptJSON};
    [[MessageClient sharedClient].httpClient POST:@"read_receipts" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            completion(receipts, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

@end
