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
        [[[UIAlertView alloc] initWithTitle:@"New Message" message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

@end
