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
@property (strong, nonatomic) NSTimer *fayeHeartbeatTimer;
@property (assign, nonatomic) BOOL hasSetAuthorizationHeader;

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
    [self initHttpClient];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedUserLoggedInNotification:) name:kUserLogginInNotification object:nil];
    return self;
}

- (void)initHttpClient
{
    NSString *urlString = [[ConstantsManager sharedConstants] messageServerURLString];
    NSString *httpURLString = [NSString stringWithFormat:@"https://%@/api/v1", urlString];
    self.httpClient = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:httpURLString]];
}

- (void)initFayeClient
{
    NSString *urlString = [[ConstantsManager sharedConstants] messageServerURLString];
    NSString *fayeURLString = [NSString stringWithFormat:@"ws://%@/streaming", urlString];
    self.fayeClient = [[TRFayeClient alloc] initWithURL:[NSURL URLWithString:fayeURLString]];
    self.fayeClient.messageDelegate = self;
}

- (void)start
{
    BOOL loggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsLoggedIn];
    NSString *userID = [CredentialStore sharedStore].userID;
    if (loggedIn && userID) {
        [self initFayeClient];
        [self.fayeClient connect];
        [self setAuthorizationHeader];
        [self subscribeForUserID:userID];
        self.fayeHeartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(fireHeartbeat:) userInfo:nil repeats:YES];
    }
}

- (void)stop
{
    [self.fayeClient disconnect];
    [self.fayeHeartbeatTimer invalidate];
}

- (void)fireHeartbeat:(id)sender
{
    
    NSString *heartbeatChannel = [NSString stringWithFormat:@"/users/heartbeat/%@", self.authExtension[@"user_id"]];
    [self.fayeClient sendMessage:@{} toChannel:heartbeatChannel usingExtension:self.authExtension];
}

- (void)setAuthorizationHeader
{
    NSString *authToken = [CredentialStore sharedStore].authToken;
    NSString *userID = [CredentialStore sharedStore].userID;
    [self.httpClient.requestSerializer setValue:authToken forHTTPHeaderField:@"authorization"];
    [self.httpClient.requestSerializer setValue:userID forHTTPHeaderField:@"user_id"];
    self.authExtension = @{@"auth_token" : authToken, @"user_id" : userID };
    self.hasSetAuthorizationHeader = YES;
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

- (void)postReceipts:(NSArray *)receipts withCompletion:(void (^)(NSArray *receipts, NSError *error))completion
{
    
//    right now we assume all the receipts to be on the same thread
    ReadReceipt *receipt = [receipts firstObject];
    NSString *channel = [NSString stringWithFormat:@"/threads/receipts/%@", receipt.message.messageThread.identifier];
    NSMutableArray *receiptJSON = [[NSMutableArray alloc] init];
    for (ReadReceipt *receipt in receipts) {
        NSDictionary *jsonValue = @{@"thread_id" : receipt.message.messageThread.identifier, @"message_id" : receipt.message.messageID, @"user_id" : [AppDelegate sharedDelegate].store.currentAccount.currentUser.identifier, @"timestamp" : @(receipt.timestamp.timeIntervalSince1970)};
        [receiptJSON addObject:jsonValue];
    }
    NSDictionary *parameters = @{@"receipts" : receiptJSON};
    [self.fayeClient sendMessage:parameters toChannel:channel usingExtension:self.authExtension withCompletion:^(NSDictionary *responseObject, NSError *error) {
        if (completion) {
            if (!error) {
                completion(nil, error);
            }
            else {
                completion(receipts, nil);
            }
        }
    }];
}

- (void)sendMessage:(Message *)message withCompletion:(void (^)(Message *message, NSError *error))completion
{
//    add guuid to message
    if (!message.uniqueID) {
        message.uniqueID = [[NSUUID UUID] UUIDString];
    }
    [message.managedObjectContext MR_saveOnlySelfAndWait];
    NSString *channel = [NSString stringWithFormat:@"/threads/messages/%@", message.messageThread.identifier];
    [self.fayeClient sendMessage:@{@"message" : @{@"author_id" : message.author.identifier, @"body" : message.text, @"guid" : message.uniqueID}} toChannel:channel usingExtension:self.authExtension withCompletion:^(NSDictionary *responseObject, NSError *error) {
        if (!error) {
//            responseObject must have a messageThread containing a single message
            NSDictionary *messageData = responseObject[@"message_thread"][@"messages"][0];
            message.messageID = messageData[@"id"];
            NSNumber *timestamp = messageData[@"timestamp"];
            message.timestamp = [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue];
            message.failed = @(NO);
        }
        else {
            message.failed = @(YES);
        }
        [message.managedObjectContext MR_saveOnlySelfAndWait];
        if (completion) {
            completion(message, error);
        }
    }];
}

- (void)refreshMessagesWithCompletion:(void (^)(NSArray *, NSArray *, NSArray *, NSError *))completion
{
    Message *message = [Message MR_findFirstOrderedByAttribute:@"timestamp" ascending:NO];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
    if (message && message.timestamp) {
//        provide a small buffer around latest message to lower risk of missing new message
        date = [message.timestamp dateByAddingTimeInterval:-60*2];
    }
    [self getMessagesSinceDate:date completion:completion];
}

- (void)getMessagesSinceDate:(NSDate *)date completion:(void (^)(NSArray *messages, NSArray *createdMessages, NSArray *createdMessageThreads, NSError *error))completion
{
    if (!self.hasSetAuthorizationHeader) {
        if (completion) {
            NSError *error = [[NSError alloc] init];
            completion(nil, nil, nil, error);
        }
        return;
    }
    NSDictionary *parameters;
    if (date) {
        parameters = @{@"timestamp" : @([date timeIntervalSince1970])};
    }
    DDLogInfo(@"getting messages with parameters %@", parameters);
    [self.httpClient GET:@"user/messages" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogInfo(@"received messages %@", responseObject);
        NSArray *createdThreads;
        NSArray *createdMessages;
        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
        NSArray *threads = [self findOrCreateMessageThreadsWithData:responseObject inManagedObjectContext:context createdMessageThreads:&createdThreads createdMessages:&createdMessages];
        if (date.timeIntervalSinceReferenceDate > 0) {
            for (Message *message in createdMessages) {
                message.messageThread.unread = @(YES);
            }
        }
        [context MR_saveOnlySelfAndWait];
        if (createdMessages) {
            [self postNotificationForNewMessages:createdMessages fetched:YES];
        }
        if (completion) {
            completion(threads, createdMessages, createdThreads, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, nil, nil, error);
        }
    }];
}

- (void)postNotificationForNewMessages:(NSArray *)messages fetched:(BOOL)fetched
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kReceivedNewMessageNotification object:nil userInfo:@{@"messages" : [messages valueForKey:@"objectID"], @"fetched" : @(fetched)}];
}

- (void)postMessageThreadWithRecipients:(NSArray *)recipients completion:(void (^)(MessageThread *messageThread, NSError *error))completion
{
    NSDictionary *parameters = @{@"message_thread" : @{@"user_ids" : [recipients valueForKey:@"identifier"]}};
    [self.httpClient POST:@"message_threads" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        MessageThread *thread = [MessageThread MR_createEntity];
        thread.identifier = responseObject[@"id"];
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
    [self findOrCreateMessageThreadWithData:messageThreadData inManagedObjectContext:context withCompletion:^(BOOL created, MessageThread *messageThread, NSArray *newMessages) {
        for (Message *message in newMessages) {
            message.messageThread.unread = @(YES);
        }
        [context MR_saveOnlySelfAndWait];
        if (newMessages) {
            [self postNotificationForNewMessages:newMessages fetched:NO];
        }
    }];
}

- (NSArray *)findOrCreateMessageThreadsWithData:(NSArray *)messageThreadsData inManagedObjectContext:(NSManagedObjectContext *)context createdMessageThreads:(NSArray **)_createdMessageThreads createdMessages:(NSArray **)_createdMessages
{
    NSMutableArray *allThreads = [[NSMutableArray alloc] init];
    NSMutableArray *allCreatedThreads = [[NSMutableArray alloc] init];
    NSMutableArray *allCreatedMessages = [[NSMutableArray alloc] init];
    for (NSDictionary *threadData in messageThreadsData) {
        BOOL createdThread = NO;
        NSArray *createdMessages;
        MessageThread *thread = [self findOrCreateMessageThreadWithData:threadData inManagedObjectContext:context created:&createdThread createdMessages:&createdMessages];
        [allThreads addObject:thread];
        if (createdThread) {
            [allCreatedThreads addObject:thread];
        }
        if (createdMessages && createdMessages.count) {
            [allCreatedMessages addObjectsFromArray:createdMessages];
        }
    }
    if (allCreatedMessages.count) {
        *_createdMessages = [NSArray arrayWithArray:allCreatedMessages];
    }
    if (allCreatedThreads.count) {
        *_createdMessageThreads = [NSArray arrayWithArray:allCreatedThreads];
    }
    return [NSArray arrayWithArray:allThreads];
}

- (void)findOrCreateMessageThreadWithData:(NSDictionary *)messageThreadData inManagedObjectContext:(NSManagedObjectContext *)context withCompletion:(void (^)(BOOL created, MessageThread *messageThread, NSArray *newMessages))completion
{
    BOOL threadCreated = NO;
    NSArray *createdMessages;
    MessageThread *thread = [self findOrCreateMessageThreadWithData:messageThreadData inManagedObjectContext:context created:&threadCreated createdMessages:&createdMessages];
    if (completion) {
        completion(threadCreated, thread, [NSArray arrayWithArray:createdMessages]);
    }
}

- (MessageThread *)findOrCreateMessageThreadWithData:(NSDictionary *)messageThreadData inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext created:(BOOL *)_created createdMessages:(NSArray **)_createdMessages
{
    NSString *identifier = messageThreadData[@"id"];
    NSArray *messagesData = messageThreadData[@"messages"];
    NSArray *usersData = messageThreadData[@"user_ids"];
    NSString *name = messageThreadData[@"name"];
    MessageThread *messageThread = [MessageThread MR_findFirstByAttribute:NSStringFromSelector(@selector(identifier)) withValue:identifier inContext:managedObjectContext];
    if (!messageThread) {
        messageThread = [MessageThread MR_createInContext:managedObjectContext];
        messageThread.identifier = identifier;
        *_created = YES;
    }
    
    if (!isEmpty(name)) {
        messageThread.name = name;
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
        *_createdMessages = [NSArray arrayWithArray:messages];
    }

    NSArray *users = [User MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"identifier IN %@", usersData] inContext:managedObjectContext];
    messageThread.recipients = [NSSet setWithArray:users];
    return messageThread;
}

- (Message *)findOrCreateMessageWithData:(NSDictionary *)messageData inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext created:(BOOL *)_created
{
    NSString *messageID = messageData[@"id"];
    NSString *author_id = messageData[@"author_id"];
    NSString *body = messageData[@"body"];
    NSNumber *timestamp = messageData[@"timestamp"];
    NSString *guid = messageData[@"guid"];
    NSArray *receipts = messageData[@"read_receipts"];
    User *author = [User MR_findFirstByAttribute:NSStringFromSelector(@selector(identifier)) withValue:author_id];
    if (!author) {
        author = [User MR_createEntity];
        author.identifier = author_id;
    }
    NSAssert(author, @"Author must exist in core data");
    Message *message = [Message MR_findFirstByAttribute:NSStringFromSelector(@selector(uniqueID)) withValue:guid];
    if (!message) {
        message = [Message MR_createInContext:managedObjectContext];
        message.messageID = messageID;
//        Once upon a time messages didn't have GUIDs
        if (![guid isEqual:[NSNull null]]) {
            message.uniqueID = guid;
        }
        *_created = YES;
    }
    message.failed = @(NO);
    message.messageText = body;
    message.author = author;
    message.timestamp = [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue];
    for (NSDictionary *receiptData in receipts) {
        BOOL receiptCreated = NO;
        [self findOrCreateReadReceiptWithData:receiptData message:message inManagedObjectContext:managedObjectContext created:&receiptCreated];
    }
    return message;
}

- (ReadReceipt *)findOrCreateReadReceiptWithData:(NSDictionary *)receiptData message:(Message *)message inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext created:(BOOL *)_created
{
    NSString *userID = receiptData[@"user_id"];
    NSNumber *timestamp = receiptData[@"timestamp"];
    NSNumber *messageID = receiptData[@"message_id"];
    
    ReadReceipt *receipt = [ReadReceipt MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"user.identifier = %@ AND message.messageID = %@",userID, messageID]];
    if (!receipt) {
        receipt = [ReadReceipt MR_createInContext:managedObjectContext];
        receipt.user = [User MR_findFirstByAttribute:@"identifier" withValue:userID inContext:managedObjectContext];
        receipt.timestamp = [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue];
        receipt.acknowledged = @(YES);
        receipt.message = message;
        *_created = YES;
    }
    return receipt;
}

@end
