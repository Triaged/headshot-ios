//
//  NotificationManager.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/13/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "NotificationManager.h"
#import "Message.h"
#import "MessageThread.h"
#import "User.h"
#import "MessageThreadViewController.h"
#import "MessageNavigationController.h"
#import "SoundPlayer.h"
#import "Device.h"

typedef void (^RemoteNotificationRegistrationBlock)(NSData *devToken, NSError *error);

@interface NotificationManager() <UIAlertViewDelegate>

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadMessageIndicator) name:kMarkedMessageThreadAsReadNotification object:nil];
    
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
    BOOL fetched = [notification.userInfo[@"fetched"] boolValue];
    NSArray *messages = notification.userInfo[@"messages"];
    NSManagedObjectID *firstMessageID = [messages firstObject];
    Message *message = (Message *)[[NSManagedObjectContext MR_contextForCurrentThread] objectWithID:firstMessageID];
    
    MessageThread *thread = message.messageThread;
    BOOL inBackground = [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
    if (!inBackground && (!self.visibleMessageThreadViewController || (![thread.objectID isEqual:self.visibleMessageThreadViewController.messageThread.objectID]))) {
//        if message fetched from server don't play sound
        if (!fetched) {
            [[SoundPlayer sharedPlayer] vibrate];
        }
        [self updateUnreadMessageIndicator];
    }
}

- (void)updateUnreadMessageIndicator
{
    BOOL unread = [MessageThread MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"unread = YES"]] > 0;
    NSString *badgeValue;
    UIImage *backButtonImage;
    if (unread) {
        badgeValue = @"•";
        backButtonImage = [[ThemeManager sharedTheme] unreadMessageBackButtonImage];
    }
    else {
        badgeValue = nil;
        backButtonImage = [[ThemeManager sharedTheme] backButtonImage];
    }
    backButtonImage = [backButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [AppDelegate sharedDelegate].tabBarController.messagesTableViewController.navigationController.tabBarItem.badgeValue = badgeValue;
    [AppDelegate sharedDelegate].tabBarController.messageNavigationController.navigationBar.backIndicatorImage = backButtonImage;
    [AppDelegate sharedDelegate].tabBarController.messageNavigationController.navigationBar.backIndicatorTransitionMaskImage = backButtonImage;
}

@end
