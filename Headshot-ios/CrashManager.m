//
//  CrashManager.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 8/13/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "CrashManager.h"
#import <Crashlytics/Crashlytics.h>

@implementation CrashManager

+ (instancetype)sharedManager
{
    static CrashManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setupForUser];
    }
    return self;
}

- (void)start
{
    [Crashlytics startWithAPIKey:@"2776a41715c04dde4ba5d15b716b66a51e353b0f"];
}

- (void)setupForUser
{
    User *loggedInUser = [AppDelegate sharedDelegate].store.currentAccount.currentUser;
    if (!loggedInUser || !loggedInUser.identifier) {
        return;
    }
    [Crashlytics setUserEmail:loggedInUser.email];
    [Crashlytics setUserIdentifier:loggedInUser.identifier];
    [Crashlytics setUserName:loggedInUser.fullName];
}

@end
