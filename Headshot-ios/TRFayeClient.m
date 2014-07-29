//
//  TRFayeClient.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/21/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "TRFayeClient.h"

@interface TRFayeMessage : NSObject

@property (strong, nonatomic, readonly) NSUUID *uuid;
@property (strong, nonatomic) NSDictionary *messageData;
@property (strong, nonatomic) TRFayeMessageCompletionBlock completionBlock;

@end

@implementation TRFayeMessage

- (instancetype)initWithMessageData:(NSDictionary *)messageData completion:(TRFayeMessageCompletionBlock)completion
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _uuid = [NSUUID UUID];
    self.completionBlock = completion;
    self.messageData = messageData;
    return self;
}

@end

@interface TRFayeClient()

@property (strong, nonatomic) NSMutableDictionary *sentMessages;
@property (strong, nonatomic) NSMutableSet *autoSubscribeChannels;

@end

@implementation TRFayeClient

- (id)initWithURL:(NSURL *)url
{
    self = [super initWithURL:url];
    if (!self) {
        return nil;
    }
    self.delegate = self;
    self.sentMessages = [[NSMutableDictionary alloc] init];
    self.autoSubscribeChannels = [[NSMutableSet alloc] init];
    
    return self;
}

- (void)sendMessage:(NSDictionary *)message toChannel:(NSString *)channel usingExtension:(NSDictionary *)extension withCompletion:(TRFayeMessageCompletionBlock)completion
{
    TRFayeMessage *fayeMessage = [[TRFayeMessage alloc] initWithMessageData:message completion:completion];
    NSMutableDictionary *messageWithID = [NSMutableDictionary dictionaryWithDictionary:message];
    [messageWithID setObject:fayeMessage.uuid.UUIDString forKey:@"guid"];
    [self.sentMessages setObject:fayeMessage forKey:fayeMessage.uuid.UUIDString];
    [super sendMessage:messageWithID toChannel:channel usingExtension:extension];
}

- (void)fayeClient:(MZFayeClient *)client didReceiveMessage:(NSDictionary *)messageData fromChannel:(NSString *)channel
{
    NSString *uuid = messageData[@"guid"];
    BOOL messageAcknowledgment = NO;
    if (uuid) {
        TRFayeMessage *message = self.sentMessages[uuid];
        if (message) {
            messageAcknowledgment = YES;
            [self.sentMessages removeObjectForKey:uuid];
        }
        if (message && message.completionBlock) {
            message.completionBlock(messageData, nil);
        }
    }
    if (messageAcknowledgment) {
        if ([self.messageDelegate respondsToSelector:@selector(fayeClient:didAcknowledgeMessage:fromChannel:)]) {
            [self.messageDelegate fayeClient:self didAcknowledgeMessage:messageData fromChannel:channel];
        }
    }
    else {
        if ([self.messageDelegate respondsToSelector:@selector(fayeClient:didReceiveMessage:fromChannel:)]) {
            [self.messageDelegate fayeClient:self didReceiveMessage:messageData fromChannel:channel];
        }
    }
}

- (void)subscribeToChannel:(NSString *)channel autoSubscribe:(BOOL)autoSubscribe
{
    if (autoSubscribe) {
        [self.autoSubscribeChannels addObject:channel];
    }
    [self subscribeToChannel:channel usingBlock:nil];
}

- (void)fayeClient:(MZFayeClient *)client didConnectToURL:(NSURL *)url
{
    NSLog(@"%@",url);
    for (NSString *channel in self.autoSubscribeChannels) {
        [self subscribeToChannel:channel autoSubscribe:YES];
    }
}
- (void)fayeClient:(MZFayeClient *)client didDisconnectWithError:(NSError *)error
{
    NSLog(@"%@",error);
}
- (void)fayeClient:(MZFayeClient *)client didUnsubscribeFromChannel:(NSString *)channel
{
    NSLog(@"%@",channel);
}
- (void)fayeClient:(MZFayeClient *)client didSubscribeToChannel:(NSString *)channel
{
    NSLog(@"%@",channel);
}
- (void)fayeClient:(MZFayeClient *)client didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
//    mark all pending sent messages as failed
    for (TRFayeMessage *message in self.sentMessages.allValues) {
        if (message.completionBlock) {
            message.completionBlock(nil, error);
        }
    }
    self.sentMessages = [[NSMutableDictionary alloc] init];
}
- (void)fayeClient:(MZFayeClient *)client didFailDeserializeMessage:(NSDictionary *)message
         withError:(NSError *)error
{
    NSLog(@"%@",error);
}



@end
