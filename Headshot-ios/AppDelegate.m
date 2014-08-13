//
//  AppDelegate.m
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "AppDelegate.h"

#import "Store.h"
#import "TRDataStoreManager.h"
#import "TRBackgroundQueue.h"
#import "LocationClient.h"
#import "MessageClient.h"
#import "CredentialStore.h"
#import "NotificationManager.h"
#import "OnboardNavigationController.h"
#import "MessageThreadViewController.h"
#import "MailComposer.h"
#import "VersionManager.h"
#import "FileLogManager.h"
#import <Crashlytics/Crashlytics.h>


@interface NSManagedObjectContext ()
+ (void)MR_setRootSavingContext:(NSManagedObjectContext *)context;
+ (void)MR_setDefaultContext:(NSManagedObjectContext *)moc;
@end


@implementation AppDelegate

+ (instancetype)sharedDelegate
{
    return [UIApplication sharedApplication].delegate;
}

- (TRTabBarController *)tabBarController
{
    if (!_tabBarController) {
        _tabBarController = [[TRTabBarController alloc] init];
    }
    return _tabBarController;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [self setDataStore];
    [[ThemeManager sharedTheme] customizeAppearance];
    [self setupLoggedInUser];
    [self setupLogging];
    [self setWindowAndRootVCForApplication:application withLaunchOptions:launchOptions];
    [NotificationManager sharedManager];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[MessageClient sharedClient] stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self setupLoggedInUser];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//    possible data loss issue where we think user is logged in but don't have data. Causes crashes so just log out
    BOOL invalid = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsLoggedIn] && ![CredentialStore sharedStore].userID;
    if (invalid) {
        [self.store logout];
    }
    
    [[MessageClient sharedClient] start];
    [[VersionManager sharedManager] notifyOfUpdate];
    [[AnalyticsManager sharedManager] appForeground];
    [[MessageClient sharedClient] refreshMessagesWithCompletion:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
}

- (void)setWindowAndRootVCForApplication:(UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSDictionary* remotePush = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remotePush) {
        [[NotificationManager sharedManager] application:application didLaunchFromRemotePush:remotePush];
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsHasFinishedOnboarding]) {
        [self.window setRootViewController:self.tabBarController];
    }
    else {
        [self showLogin];
    }

    [self.window makeKeyAndVisible];
}

- (void)showLogin
{
    [AppDelegate sharedDelegate].tabBarController = nil;
    self.window.rootViewController = [[OnboardNavigationController alloc] init];
}

- (void)setupLoggedInUser
{
    self.store = [[Store alloc] init];
    
    // Preload the MailComposer (for speed)
    [MailComposer sharedComposer];
   
    self.geofencer = [LocationClient sharedClient];
}

-(void) setupLogging {
    [Crashlytics startWithAPIKey:@"2776a41715c04dde4ba5d15b716b66a51e353b0f"];
    [[FileLogManager sharedManager] setUpFileLogging];
}


-(void)setDataStore {
    
    [NSManagedObject setDefaultBackgroundQueue:[TRBackgroundQueue sharedInstance]];
    
    [NSManagedObject registerDefaultBackgroundThreadManagedObjectContextWithAction:^NSManagedObjectContext *{
        return [TRDataStoreManager sharedInstance].backgroundThreadManagedObjectContext;
    }];
    
    [NSManagedObject registerDefaultMainThreadManagedObjectContextWithAction:^NSManagedObjectContext *{
        return [TRDataStoreManager sharedInstance].mainThreadManagedObjectContext;
    }];
    
    [SLObjectConverter setDefaultDateTimeFormat:@"yyyy-MM-dd'T'HH:mm:ss.sssZ"];
    [SLAttributeMapping registerDefaultObjcNamingConvention:@"identifier" forJSONNamingConvention:@"id"];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:kPersistentStoreName];
    [NSManagedObjectContext MR_setDefaultContext:[TRDataStoreManager sharedInstance].mainThreadManagedObjectContext];
    
}

- (void)logout
{
    [[AnalyticsManager sharedManager] logout];
    [SVProgressHUD show];
    [self.store.currentAccount logoutWithCompletion:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [self.store logout];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Logout failed. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (void)setTopViewControllerToMessageThreadViewControllerWithID:(NSString *)threadID
{
    MessageThreadViewController *messageThreadViewControllor = [[MessageThreadViewController alloc] initWithThreadID:threadID];
    self.window.rootViewController = self.tabBarController;
    [self.tabBarController selectMessagesViewController];
    UINavigationController *navigationController = (UINavigationController *)self.tabBarController.selectedViewController;
    [navigationController popToRootViewControllerAnimated:NO];
    [navigationController pushViewController:messageThreadViewControllor animated:NO];
}

#pragma mark - notifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[NotificationManager sharedManager] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[NotificationManager sharedManager] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[NotificationManager sharedManager] application:application didReceiveRemoteNotification:userInfo];
}

@end
