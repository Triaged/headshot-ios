//
//  SinchClient.m
//  Headshot-ios
//
//  Created by Charlie White on 5/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "SinchClient.h"
#import "Message.h"
#import "MessageThread.h"
#import "User.h"
#import "HeadshotAPIClient.h"
#import "Sinch/SINPushPair.h"

@implementation SinchClient

#pragma mark -

+ (instancetype)sharedClient {
    static SinchClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SinchClient alloc] init];
    });
    
    return _sharedClient;
}

- (id<SINClient>)client {
    return _client;
}

- (void)initSinchClientWithUserId:(NSString *)userId {
    if (!_client) {
        _client = [Sinch clientWithApplicationKey:@"42c9fd75-a981-4d9e-ba79-1c7647df9553"
                                applicationSecret:@"wbnKEXplqUWSDMceOSd4hg=="
                                  environmentHost:@"sandbox.sinch.com"
                                           userId:userId];
        
        
        
        [_client setSupportMessaging:YES];
        [_client setSupportPushNotifications:YES];
        
        _client.delegate = self;
        
        [_client start];
        [_client startListeningOnActiveConnection];
    }
}

- (void)logoutOfSinchClient {
    [_client stopListeningOnActiveConnection];
    [_client stop];
    
    _client = nil;
}

#pragma mark - SINClientDelegate

- (void)clientDidStart:(id<SINClient>)client {
    NSLog(@"Sinch client started successfully (version: %@)", [Sinch version]);
    client.messageClient.delegate = self;
}

- (void)clientDidStop:(id<SINClient>)client {
    NSLog(@"Sinch client stopped");
}

- (void)clientDidFail:(id<SINClient>)client error:(NSError *)error {
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)client:(id<SINClient>)client
    logMessage:(NSString *)message
          area:(NSString *)area
      severity:(SINLogSeverity)severity
     timestamp:(NSDate *)timestamp {
    
    if (severity == SINLogSeverityCritical) {
        NSLog(@"%@", message);
    }
}

#pragma mark - SINMessageClientDelegate

- (void)messageClient:(id<SINMessageClient>)messageClient didReceiveIncomingMessage:(id<SINMessage>)message {
    NSLog(@"did receive incoming message");
    
//    HACK: do nothing if the user hasn't finished onboarding yet. Prevents onslaught of old messages
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsHasFinishedOnboarding]) {
        return;
    }
    //find or create message thread
    NSString *identifier = message.senderId;
    User *sender = [User MR_findFirstByAttribute:@"identifier" withValue:identifier];
    MessageThread *thread = [self createOrFindThreadForRecipient:sender];
    
    Message *newMessage = [self createMessageWithText:message.text andAuthor:sender andTimeStamp:message.timestamp andThread:thread];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReceivedNewMessageNotification object:nil userInfo:@{@"thread" : thread, @"message" : newMessage}];
}

- (void)messageSent:(id<SINMessage>)message recipientId:(NSString *)recipientId {
    Message *sentMessage = [self messageForSINMessage:message];
    sentMessage.failed = @(NO);
    sentMessage.timestamp = [message timestamp];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageSentNotification object:nil userInfo:@{@"message" : sentMessage.objectID}];
}
    
- (void)messageDelivered:(id<SINMessageDeliveryInfo>)info {
    NSLog(@"Message to %@ was successfully delivered", info.recipientId);
}

- (void)messageFailed:(id<SINMessage>)message info:(id<SINMessageFailureInfo>)failureInfo {
    NSLog(@"Failed delivering message to %@. Reason: %@", failureInfo.recipientId,
          [failureInfo.error localizedDescription]);
    Message *failedMessage = [self messageForSINMessage:message];
    failedMessage.failed = @(YES);
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageFailedNotification object:nil userInfo:@{@"message" : failedMessage.objectID}];
}

- (void)message:(id<SINMessage>)message shouldSendPushNotifications:(NSArray *)pushPairs {
    NSLog(@"Recipient not online. \
          Should notify recipient using push (not implemented in this demo app). \
          Please refer to the documentation for a comprehensive description.");
    ;
    
    HeadshotAPIClient *client = [HeadshotAPIClient sharedClient];
    
    NSDictionary *params = nil;
    
    for (id<SINPushPair> pair in pushPairs) {
        NSString * deviceToken = [[pair.pushData description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
        params = @{ @"push_service" : @{ @"push_token" : deviceToken, @"payload" : pair.pushPayload, @"message_body" : message.text } };
        
        [client POST:@"push_services" parameters: params
             success:^(NSURLSessionDataTask *task, id abc) {
                 NSLog(@"%@", abc);
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 NSLog(@"%@", error);
             }];
    }
}

- (Message *)messageForSINMessage:(id<SINMessage>)message
{
    return [Message MR_findFirstByAttribute:@"uniqueID" withValue:[message messageId]];
}

-(MessageThread *)createOrFindThreadForRecipient:(User *)recipient {
    
    MessageThread *thread = [MessageThread MR_findFirstByAttribute:@"recipient" withValue:recipient];
    if (thread == nil) {
        
        thread = [MessageThread MR_createEntity];
        thread.lastMessageTimeStamp = [NSDate date];
        thread.recipient = recipient;
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    
    return thread;
}

- (Message *)createMessageWithText:(NSString *)text andAuthor:(User *)user andTimeStamp:timestamp andThread:(MessageThread *)thread {
    Message *newMesage = [Message MR_createEntity];
    
    newMesage.timestamp = timestamp;
    newMesage.author = user;
    newMesage.messageThread = thread;
    newMesage.messageText = text;
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return newMesage;
}

- (NSString *)userIDForSIN:(NSString *)sin
{
    id<SINNotificationResult> result = [self.client relayRemotePushNotificationPayload:sin];
    NSString *senderID = [[result messageResult] senderId];
    return senderID;
}

@end
