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
#import "NotificationManager.h"
#import "Device.h"
#import "OfficeLocation.h"



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
    
    // Reset Badge Count
    if([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [account resetBadgeCount];
    }
    
    [[[Device alloc] initWithDevice:[UIDevice currentDevice] token:nil] postDeviceWithSuccess:nil failure:nil];
    [[SinchClient sharedClient] initSinchClientWithUserId:account.identifier];
    
    [Company companyWithCompletionHandler:^(Company *company, NSError *error) {
        self.hasStoredCompany = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kHasStoredCompanyNotification object:nil];
    }];
    
    
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
    [[SinchClient sharedClient].client stop];
    [[CredentialStore sharedClient] clearSavedCredentials];
    [[TRDataStoreManager sharedInstance] cleanAndResetupDB];
}


- (void) userSignedOut
{
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
    
    //[Intercom endSession];
    
    
}


+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    return dateFormatter;
}





@end
