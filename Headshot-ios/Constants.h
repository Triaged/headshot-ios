#import <CocoaLumberjack/DDLog.h>

//api
extern NSString * const HeadshotAPIBaseURLString;
extern NSString * const StagingAPIBaseURLString;

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

