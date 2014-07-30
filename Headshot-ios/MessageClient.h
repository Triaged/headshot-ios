//
//  MessageClient.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/21/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "TRFayeClient.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "Message.h"
#import "MessageThread.h"
#import "User.h"

@interface MessageClient : NSObject <TRFayeClientMessageDelegate>

@property (strong, nonatomic) TRFayeClient *fayeClient;
@property (strong, nonatomic) AFHTTPSessionManager *httpClient;

+ (instancetype)sharedClient;
- (void)start;
- (void)stop;
- (void)subscribeForUserID:(NSString *)userID;
- (void)sendMessage:(Message *)message withCompletion:(void (^)(Message *message, NSError *error))completion;
- (void)postMessageThreadWithRecipients:(NSArray *)recipients completion:(void (^)(MessageThread *messageThread, NSError *error))completion;
- (void)refreshMessagesWithCompletion:(void (^)(NSArray *messages, NSArray *createdMessages, NSArray *createdMessageThreads, NSError *error))completion;
- (void)getMessagesSinceDate:(NSDate *)date completion:(void (^)(NSArray *messages, NSArray *createdMessages, NSArray *createdMessageThreads, NSError *error))completion;

@end
