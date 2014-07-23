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

@interface MessageClient()

@property (strong, nonatomic) NSDictionary *authExtension;

@end

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
    self.fayeClient.messageDelegate = self;
    self.httpClient = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:httpURLString]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedUserLoggedInNotification:) name:kUserLogginInNotification object:nil];
    return self;
}

- (void)start
{
    BOOL loggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsLoggedIn];
    if (loggedIn) {
        [self setAuthorizationHeader];
        [self subscribeForUserID:[AppDelegate sharedDelegate].store.currentAccount.currentUser.identifier];
    }
}

- (void)setAuthorizationHeader
{
    NSString *authToken = [CredentialStore sharedStore].authToken;
    NSString *userID = [AppDelegate sharedDelegate].store.currentAccount.currentUser.identifier;
    [self.httpClient.requestSerializer setValue:authToken forHTTPHeaderField:@"authorization"];
    [self.httpClient.requestSerializer setValue:userID forHTTPHeaderField:@"user_id"];
    self.authExtension = @{@"auth_token" : authToken, @"user_id" : userID };
}

- (void)receivedUserLoggedInNotification:(NSNotification *)notification
{
    NSAssert([CredentialStore sharedStore].authToken, @"Must have auth token if logged in");
    NSAssert([AppDelegate sharedDelegate].store.currentAccount, @"Must have an account if logged in");
    NSAssert(([AppDelegate sharedDelegate].store.currentAccount.currentUser), @"Must have a user if logged in");
    [self start];
}
     

- (void)subscribeForUserID:(NSString *)userID
{
    NSString *channel = [NSString stringWithFormat:@"/users/messages/%@", userID];
    [self.fayeClient setExtension:self.authExtension forChannel:channel];
    [self.fayeClient subscribeToChannel:channel autoSubscribe:YES];
}

- (void)sendMessage:(Message *)message withCompletion:(void (^)(Message *message, NSError *error))completion
{
    NSString *channel = [NSString stringWithFormat:@"/threads/messages/%@", message.messageThread.identifier];
    [self.fayeClient sendMessage:@{@"message" : @{@"author_id" : message.author.identifier, @"body" : message.text,  @"timestamp" : [NSDate date].badgeFormattedDate}} toChannel:channel usingExtension:self.authExtension withCompletion:^(NSDictionary *responseObject, NSError *error) {
        if (!error) {
//            responseObject must have a messageThread containing a single message
            NSDictionary *messageData = responseObject[@"messageThread"][@"messages"][0];
            message.messageID = messageData[@"_id"];
            [message.managedObjectContext MR_saveOnlySelfAndWait];
            if (completion) {
                completion(message, nil);
            }
        }
        else {
            if (completion) {
                completion(nil, error);
            }
        }
    }];
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

#pragma mark - Message Client Delegate
- (void)fayeClient:(TRFayeClient *)fayeClient didReceiveMessage:(NSDictionary *)messageData fromChannel:(NSString *)channel
{
    NSString *messageThreadKey = @"message_thread";
    if (![messageData.allKeys containsObject:messageThreadKey]) {
        return;
    }
    
    NSDictionary *messageThreadData = messageData[messageThreadKey];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    [self findOrCreateMessageThreadWithData:messageThreadData inManagedObjectContect:context withCompletion:^(BOOL created, MessageThread *messageThread, NSArray *newMessages) {
        [context MR_saveOnlySelfAndWait];
        if (newMessages) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kReceivedNewMessageNotification object:nil userInfo:nil];
        }
    }];
}

- (void)findOrCreateMessageThreadWithData:(NSDictionary *)messageThreadData inManagedObjectContect:(NSManagedObjectContext *)context withCompletion:(void (^)(BOOL created, MessageThread *messageThread, NSArray *newMessages))completion
{
    BOOL threadCreated = NO;
    NSArray *createdMessages;
    MessageThread *thread = [self findOrCreateMessageThreadWithData:messageThreadData inManagedObjectContext:context created:&threadCreated createdMessages:&createdMessages];
    if (completion) {
        completion(threadCreated, thread, [NSArray arrayWithArray:createdMessages]);
    }
}

- (MessageThread *)findOrCreateMessageThreadWithData:(NSDictionary *)messageThreadData inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext created:(BOOL *)created createdMessages:(NSArray **)createdMessages
{
    NSString *identifier = messageThreadData[@"_id"];
    NSArray *messagesData = messageThreadData[@"messages"];
    NSArray *usersData = messageThreadData[@"user_ids"];
    MessageThread *messageThread = [MessageThread MR_findFirstByAttribute:NSStringFromSelector(@selector(identifier)) withValue:identifier inContext:managedObjectContext];
    if (!messageThread) {
        messageThread = [MessageThread MR_createInContext:managedObjectContext];
        *created = YES;
    }
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (NSDictionary *messageData in messagesData) {
        BOOL messageCreated = NO;
        Message *message = [self findOrCreateMessageWithData:messageData inManagedObjectContext:managedObjectContext created:&messageCreated];
        if (messageCreated) {
            [messages addObject:message];
        }
        message.messageThread = messageThread;
    }
    if (messages.count) {
        *createdMessages = [NSArray arrayWithArray:messages];
    }

    NSArray *users = [User MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"identifier IN %@", usersData] inContext:managedObjectContext];
    messageThread.recipients = [NSSet setWithArray:users];
    return messageThread;
}

- (Message *)findOrCreateMessageWithData:(NSDictionary *)messageData inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext created:(BOOL *)created
{
    NSString *messageID = messageData[@"_id"];
    NSString *author_id = messageData[@"author_id"];
    NSString *body = messageData[@"body"];
    NSString *timestamp = messageData[@"timestamp"];
    User *author = [User MR_findFirstByAttribute:NSStringFromSelector(@selector(identifier)) withValue:author_id];
    NSAssert(author, @"Author must exist in core data");
    Message *message = [Message MR_findFirstByAttribute:NSStringFromSelector(@selector(messageID)) withValue:messageID];
    if (!message) {
        message = [Message MR_createInContext:managedObjectContext];
        *created = YES;
    }
    message.messageText = body;
    message.author = author;
    message.timestamp = [NSDate dateFromFormattedString:timestamp];
    return message;
}
     
     

@end
