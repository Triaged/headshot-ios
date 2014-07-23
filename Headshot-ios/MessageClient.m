//
//  MessageClient.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/21/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "MessageClient.h"
#import "NSDate+BadgeFormattedDate.h"
#import "CredentialStore.h"

@implementation MessageClient

+ (instancetype)sharedClient
{
    static MessageClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    NSString *urlString = CurrentServerEnvironment == ServerEnvironmentProduction ? ProductionMessageServerURLString : StagingMessageServerURLString;
    NSString *fayeURLString = [NSString stringWithFormat:@"ws://%@/streaming", urlString];
    NSString *httpURLString = [NSString stringWithFormat:@"http://%@/api/v1", urlString];
    self.fayeClient = [[TRFayeClient alloc] initWithURL:[NSURL URLWithString:fayeURLString]];

    
    
    self.httpClient = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:httpURLString]];
    return self;
}
     

- (void)subscribeForUserID:(NSString *)userID
{
    NSString *channel = [NSString stringWithFormat:@"/users/messages/%@", userID];
    [self.fayeClient setExtension:[self fayeExtension] forChannel:channel];
    [self.fayeClient subscribeToChannel:channel autoSubscribe:YES];
}
     
-(NSDictionary *)fayeExtension{
    NSString *userID = [AppDelegate sharedDelegate].store.currentAccount.identifier;
    CredentialStore *store = [[CredentialStore alloc] init];
    NSString *authToken = [store authToken];
    return @{@"auth_token" : authToken, @"user_id" : userID };
}

- (void)sendMessage:(Message *)message withCompletion:(TRFayeMessageCompletionBlock)completion
{
    NSString *channel = [NSString stringWithFormat:@"/threads/messages/%@", message.messageThread.identifier];
    [self.fayeClient sendMessage:@{@"message" : @{@"author_id" : message.author.identifier, @"body" : message.text,  @"timestamp" : [NSDate date].badgeFormattedDate}} toChannel:channel usingExtension:[self fayeExtension] withCompletion:completion];
}

- (void)createMessageThreadWithRecipients:(NSArray *)recipients completion:(void (^)(MessageThread *messageThread, NSError *error))completion
{
    NSDictionary *parameters = @{@"message_thread" : @{@"user_ids" : [recipients valueForKey:@"identifier"]}};
    [self.httpClient POST:@"message_threads" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        MessageThread *thread = [MessageThread MR_createEntity];
        thread.identifier = responseObject[@"_id"];
        NSArray *userIDs = responseObject[@"user_ids"];
        NSArray *recipients = [User MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"identifier IN %@", userIDs]];
        thread.recipients = [NSSet setWithArray:recipients];
        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
        if (completion) {
            completion(thread, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}
     
     

@end
