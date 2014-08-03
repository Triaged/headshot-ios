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
NSString * const ProductionMessageServerURLString;
NSString * const StagingMessageServerURLString;

//notification center
extern NSString * const kReceivedNewMessageNotification;
extern NSString * const kRequestAuthorizationErrorNotification;
extern NSString * const kMessageFailedNotification;
extern NSString * const kMessageSentNotification;
extern NSString * const kHasStoredCompanyNotification;
extern NSString * const kUserLogginInNotification;


//user defaults
extern NSString * const kUserDefaultsLoggedIn;
extern NSString * const kUserDefaultsHasRequestedLocationPermission;
extern NSString * const kUserDefaultsHasRequestedPushPermission;
extern NSString * const kUserDefaultsHasFinishedOnboarding;
extern NSString * const kUserDefaultsDeviceIdentifier;

//core data
extern NSString * const kPersistentStoreName;


//logging
static const int ddLogLevel = LOG_LEVEL_INFO;

