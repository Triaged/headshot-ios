//
//  TRFayeClient.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/21/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "MZFayeClient.h"

typedef void (^TRFayeMessageCompletionBlock)(NSDictionary *responseObject, NSError *error);

@class TRFayeClient;
@protocol TRFayeClientMessageDelegate <NSObject>

- (void)fayeClient:(TRFayeClient *)fayeClient didReceiveMessage:(NSDictionary *)messageData fromChannel:(NSString *)channel;

@end

@interface TRFayeClient : MZFayeClient <MZFayeClientDelegate>

- (void)sendMessage:(NSDictionary *)message toChannel:(NSString *)channel usingExtension:(NSDictionary *)extension withCompletion:(TRFayeMessageCompletionBlock)completion;
- (void)subscribeToChannel:(NSString *)channel autoSubscribe:(BOOL)autoSubscribe;

@property (weak, nonatomic) id<TRFayeClientMessageDelegate> messageDelegate;

@end
