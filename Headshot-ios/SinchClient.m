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
        _client = [Sinch clientWithApplicationKey:@"05f0820c-3572-4b92-9bab-e8388d25ded4"
                                applicationSecret:@"jTF+f7Az90aUNrF6p+4VHA=="
                                  environmentHost:@"sandbox.sinch.com"
                                           userId:userId];
        
        
        
        [_client setSupportMessaging:YES];
        [_client setSupportPushNotifications:YES];
        
        _client.delegate = self;
        
        [_client start];
        [_client startListeningOnActiveConnection];
    }
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
    //find or create message thread
    NSString *identifier = message.senderId;
    User *sender = [User MR_findFirstByAttribute:@"identifier" withValue:identifier];
    MessageThread *thread = [self createOrFindThreadForRecipient:sender];
    
    [self createMessageWithText:message.text andAuthor:sender andThread:thread];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@", thread.objectID] object:nil];
}

- (void)messageSent:(id<SINMessage>)message recipientId:(NSString *)recipientId {
    NSLog(@"Message sent to %@", recipientId);
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
    }
    
    
    [client POST:@"push_services" parameters: params
                                   success:^(NSURLSessionDataTask *task, id abc) {
                                       NSLog(@"%@", abc);
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       NSLog(@"%@", error);
                                   }];
}

- (void)messageDelivered:(id<SINMessageDeliveryInfo>)info {
    NSLog(@"Message to %@ was successfully delivered", info.recipientId);
}

- (void)messageFailed:(id<SINMessage>)message info:(id<SINMessageFailureInfo>)failureInfo {
    NSLog(@"Failed delivering message to %@. Reason: %@", failureInfo.recipientId,
          [failureInfo.error localizedDescription]);
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

- (void)createMessageWithText:(NSString *)text andAuthor:(User *)user andThread:(MessageThread *)thread {
    Message *newMesage = [Message MR_createEntity];
    newMesage.timestamp = [NSDate date];
    newMesage.author = user;
    newMesage.messageThread = thread;
    newMesage.messageText = text;
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

@end
