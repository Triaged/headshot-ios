//
//  NotificationManager.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/13/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "NotificationManager.h"
#import <CMNavBarNotificationView.h>
#import <MPGNotification.h>
#import "Message.h"
#import "MessageThread.h"
#import "User.h"
#import "MessageThreadViewController.h"
#import "Device.h"

typedef void (^RemoteNotificationRegistrationBlock)(NSData *devToken, NSError *error);

@interface NotificationManager() <UIAlertViewDelegate>

@property (assign, nonatomic) BOOL isDisplayingAlert;
@property (strong, nonatomic) RemoteNotificationRegistrationBlock remoteNotificationRegistrationCompletion;

@end

@implementation NotificationManager

+ (NotificationManager *)sharedManager
{
    static NotificationManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [NotificationManager new];
    });
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewMessageNotification:) name:kReceivedNewMessageNotification object:nil];
    
    return self;
}

- (void)registerForRemoteNotificationsWithCompletion:(void (^)(NSData *, NSError *))completion
{
    self.remoteNotificationRegistrationCompletion = completion;
    BOOL shouldRegisterForPush = YES;
#ifdef DEBUG
    shouldRegisterForPush = NO;
#endif
    if (shouldRegisterForPush) {
        UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
        self.remoteNotificationRegistrationCompletion = completion;
    }
    else {
        NSError *error = nil;
        [self executePushNotificationRegistrationCompletionBlockWithDeviceToken:nil error:error];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[[Device alloc] initWithDevice:[UIDevice currentDevice] token:deviceToken] postDeviceWithCompletion:nil];
    if (self.remoteNotificationRegistrationCompletion) {
        self.remoteNotificationRegistrationCompletion(deviceToken, nil);
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [self executePushNotificationRegistrationCompletionBlockWithDeviceToken:nil error:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (application.applicationState == UIApplicationStateActive) {
        return;
    }
    [self launchMessageThreadFromNotification:userInfo];
}

- (void)application:(UIApplication *)application didLaunchFromRemotePush:(NSDictionary *)userInfo
{
    [self launchMessageThreadFromNotification:userInfo];
}

- (void)launchMessageThreadFromNotification:(NSDictionary *)userInfo
{
    NSString *messageThreadID = userInfo[@"thread_id"];
    if (messageThreadID) {
        [[AppDelegate sharedDelegate] setTopViewControllerToMessageThreadViewControllerWithID:messageThreadID];
    }
}

- (void)executePushNotificationRegistrationCompletionBlockWithDeviceToken:(NSData *)deviceToken error:(NSError *)error
{
    if (self.remoteNotificationRegistrationCompletion) {
        self.remoteNotificationRegistrationCompletion(deviceToken, nil);
        self.remoteNotificationRegistrationCompletion = nil;
    }
}

- (void)receivedNewMessageNotification:(NSNotification *)notification
{
//    if the message was fetched from server (instead of pushed) do not show notification
    BOOL fetched = [notification.userInfo[@"fetched"] boolValue];
    if (fetched) {
        return;
    }
    NSArray *messages = notification.userInfo[@"messages"];
    NSManagedObjectID *firstMessageID = [messages firstObject];
    Message *message = (Message *)[[NSManagedObjectContext MR_contextForCurrentThread] objectWithID:firstMessageID];
    
    MessageThread *thread = message.messageThread;
    BOOL inBackground = [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
    if (!inBackground && (!self.visibleMessageThreadViewController || (![thread.objectID isEqual:self.visibleMessageThreadViewController.messageThread.objectID]))) {
        if (!self.isDisplayingAlert) {
            MPGNotification *notification = [MPGNotification notificationWithTitle:message.author.firstName subtitle:message.text backgroundColor:[[ThemeManager sharedTheme] orangeColor]  iconImage:nil];
            notification.duration = 5;
            notification.dismissHandler = ^(MPGNotification *notification) {
                self.isDisplayingAlert = NO;
            };
            self.isDisplayingAlert = YES;
            [notification showWithButtonHandler:^(MPGNotification *notification, NSInteger buttonIndex) {
                [[AppDelegate sharedDelegate] setTopViewControllerToMessageThreadViewControllerWithID:thread.identifier];
            }];
        }
    }
}

@end
