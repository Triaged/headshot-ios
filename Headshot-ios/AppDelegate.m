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
#import "Geofencer.h"
#import "SinchClient.h"
#import "CredentialStore.h"
#import "NotificationManager.h"
#import "OnboardNavigationController.h"
#import "MailComposer.h"


@interface NSManagedObjectContext ()
+ (void)MR_setRootSavingContext:(NSManagedObjectContext *)context;
+ (void)MR_setDefaultContext:(NSManagedObjectContext *)moc;
@end


@implementation AppDelegate

+ (instancetype)sharedDelegate
{
    return [UIApplication sharedApplication].delegate;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [NotificationManager sharedManager];
    [self setDataStore];
    [[ThemeManager sharedTheme] customizeAppearance];
    [self setupLoggedInUser];
    [self setWindowAndRootVC];
    
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[SinchClient sharedClient].client stopListeningOnActiveConnection];
    [[SinchClient sharedClient].client stop];

    [MagicalRecord cleanUp];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // get previously initiated Sinch client
    id<SINClient> client = [SinchClient sharedClient].client;
    [client registerPushNotificationData:deviceToken];
}

- (void)setWindowAndRootVC {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.tabBarController = [[TRTabBarController alloc] init];
    
    if ([[CredentialStore sharedClient] isLoggedIn]) {
        [self.window setRootViewController:self.tabBarController];
    }
    else {
        self.window.rootViewController = [[OnboardNavigationController alloc] init];
    }

    [self.window makeKeyAndVisible];
}

//
- (void)setupLoggedInUser
{
    self.store = [[Store alloc] init];
    
    // Preload the MailComposer (for speed)
    [MailComposer sharedComposer];
    
    
    //  if ([self.store.currentAccount isLoggedIn]) {
     //       if([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
     //           [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //            [self.store.account resetAPNSPushCount];
    
    //            [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    //        }
    //    }
    
    self.geofencer = [Geofencer sharedClient];

}

-(void)setDataStore{
    
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
}

- (void)logout
{
    [self.store logout];
    self.window.rootViewController = [[OnboardNavigationController alloc] init];
}

@end
