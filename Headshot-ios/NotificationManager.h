//
//  NotificationManager.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/13/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageThreadViewController.h"

@class MessageThreadViewController;

@interface NotificationManager : NSObject

@property (strong, nonatomic) MessageThreadViewController *visibleMessageThreadViewController;

+ (NotificationManager *)sharedManager;
- (void)registerForRemoteNotificationsWithCompletion:(void (^)(NSData *devToken, NSError *error))completion;

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)application:(UIApplication *)application didLaunchFromRemotePush:(NSDictionary *)userInfo;

@end
