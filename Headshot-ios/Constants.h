#import <CocoaLumberjack/DDLog.h>

//api
typedef enum {
    ServerEnvironmentStaging=0,
    ServerEnvironmentProduction,
    ServerEnvironmentDevelopment
} ServerEnvironment;
extern ServerEnvironment CurrentServerEnvironment;
extern NSString * const HeadshotAPIBaseURLString;
extern NSString * const StagingAPIBaseURLString;
extern NSString * const SinchProductionAppKey;
extern NSString * const SinchProductionAppSecret;
extern NSString * const SinchProdunctionEnvironmentHost;
extern NSString * const SinchStagingAppKey;
extern NSString * const SinchStagingAppSecret;
extern NSString * const SinchStagingEnvironmentHost;

//notification center
extern NSString * const kReceivedNewMessageNotification;

extern NSString * const kMessageFailedNotification;
extern NSString * const kMessageSentNotification;
extern NSString * const kHasStoredCompanyNotification;


//user defaults
extern NSString * const kUserDefaultsLoggedIn;
extern NSString * const kUserDefaultsHasRequestedLocationPermission;
extern NSString * const kUserDefaultsHasRequestedPushPermission;
extern NSString * const kUserDefaultsHasFinishedOnboarding;

//core data
extern NSString * const kPersistentStoreName;


//logging
static const int ddLogLevel = LOG_LEVEL_INFO;

