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
#import "SinchClient.h"

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
#if !DEBUG
    UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    self.remoteNotificationRegistrationCompletion = completion;
#else
    NSError *error = nil;
    [self executePushNotificationRegistrationCompletionBlockWithDeviceToken:nil error:error];
#endif
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // get previously initiated Sinch client
    id<SINClient> client = [SinchClient sharedClient].client;
    [client registerPushNotificationData:deviceToken];
    if (self.remoteNotificationRegistrationCompletion) {
        self.remoteNotificationRegistrationCompletion(deviceToken, nil);
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [self executePushNotificationRegistrationCompletionBlockWithDeviceToken:nil error:error];
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
    Message *message = notification.userInfo[@"message"];
    MessageThread *thread = notification.userInfo[@"thread"];
    BOOL inBackground = [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
    if (inBackground) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"%@: %@", message.author.firstName, message.text];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    else if (!self.visibleMessageThreadViewController || (![thread.objectID isEqual:self.visibleMessageThreadViewController.messageThread.objectID])) {
        NSString *text = [NSString stringWithFormat:@"%@: %@", message.author.firstName, message.text];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Message" message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self showAlertView:alertView];
    }
}

- (void)showAlertView:(UIAlertView *)alertView
{
    if (self.isDisplayingAlert) {
        return;
    }
    self.isDisplayingAlert = YES;
    alertView.delegate = self;
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.isDisplayingAlert = NO;
}

@end
