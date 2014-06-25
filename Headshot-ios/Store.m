//
//  Store.m
//  Docked-ios
//
//  Created by Charlie White on 10/3/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import "Store.h"
#import "HeadshotAPIClient.h"
#import "AppDelegate.h"
#import "CredentialStore.h"
#import "SinchClient.h"
#import "User.h"
#import "LoginViewController.h"
#import "NotificationManager.h"



@interface Store ()
    @property (nonatomic,strong) NSString *minID;
@end

@implementation Store

+ (instancetype)store
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        if ([[CredentialStore sharedClient] isLoggedIn]) {
            [self setUpAccount:[self currentAccount]];
        }
    }
    return self;
}


#pragma mark - Remote Updates

- (void) fetchRemoteUserAccount
{
    [Account currentAccountWithCompletionHandler:^(Account *account, NSError *error) {}];
}

- (Account *)currentAccount {
    return [Account MR_findFirst];
}

- (Company *)currentCompany {
    return [Company MR_findFirst];
}


#pragma mark - User Authentication
- (void)userLoggedInWithAccount:(Account *)account
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsLoggedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setUpAccount:account];
}

- (void)setUpAccount:(Account *)account
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsHasRequestedPushPermission]) {
        [[NotificationManager sharedManager] registerForRemoteNotificationsWithCompletion:nil];
    }
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    //    [Account currentAccountWithCompletionHandler:^(Account *account, NSError *error) {
    //        if (error == nil) {
    [[SinchClient sharedClient] initSinchClientWithUserId:account.identifier];
    
    [Company companyWithCompletionHandler:^(Company *company, NSError *error) {}];
    [User usersWithCompletionHandler:^(NSArray *users, NSError *error){}];
    //        }
    
    //        Mixpanel *mixpanel = [Mixpanel sharedInstance];
    //        [mixpanel identify:account.identifier];
    //        [mixpanel track:@"signup" properties:@{@"id": account.identifier,
    //                                               @"email" : account.currentUser.email,
    //                                               @"company" : account.companyName}];
    
    //[Intercom beginSessionForUserWithUserId:account.identifier andEmail:account.currentUser.email];
    
    //    }];
}

-(void)logout
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsLoggedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[CredentialStore sharedClient] clearSavedCredentials];
    //[[NSNotificationCenter defaultCenter] postNotification:@"logout"];
    
}


- (void) userSignedOut
{
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults removeObjectForKey:@"min_updated_at"];
    [standardDefaults removeObjectForKey:@"companyValidated"];
    [standardDefaults synchronize];
    
    //[Intercom endSession];
    
    //[[AppDelegate sharedDelegate].persistentStack resetPersistentStore];
}


+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    return dateFormatter;
}





@end
