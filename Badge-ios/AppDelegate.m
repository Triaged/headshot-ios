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
#import "SinchClient.h"
#import "CredentialStore.h"
#import "NotificationManager.h"
#import "OnboardNavigationController.h"
#import "MessageThreadViewController.h"
#import "MailComposer.h"
#import "VersionManager.h"
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
    
    [NotificationManager sharedManager];
    [self setDataStore];
    [[ThemeManager sharedTheme] customizeAppearance];
    [self setupLoggedInUser];
    [self setupLogging];
    [self setWindowAndRootVCForApplication:application withLaunchOptions:launchOptions];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[SinchClient sharedClient].client stopListeningOnActiveConnection];
    [[SinchClient sharedClient].client stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self setupLoggedInUser];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[SinchClient sharedClient].client start];
    [[SinchClient sharedClient].client startListeningOnActiveConnection];
    [[VersionManager sharedManager] notifyOfUpdate];
    [[AnalyticsManager sharedManager] appForeground];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[SinchClient sharedClient].client stopListeningOnActiveConnection];
    [[SinchClient sharedClient].client stop];

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
        self.window.rootViewController = [[OnboardNavigationController alloc] init];
    }

    [self.window makeKeyAndVisible];
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
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Headshot.sqlite"];
    [NSManagedObjectContext MR_setDefaultContext:[TRDataStoreManager sharedInstance].mainThreadManagedObjectContext];
    
}

- (void)logout
{
    [[AnalyticsManager sharedManager] logout];
    [self.store logout];
    self.window.rootViewController = [[OnboardNavigationController alloc] init];
}

- (void)setTopViewControllerToMessageThreadViewControllerWithAuthorID:(NSString *)authorID
{
    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:authorID];
    MessageThreadViewController *messageThreadViewControllor = [[MessageThreadViewController alloc] initWithRecipient:user];
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