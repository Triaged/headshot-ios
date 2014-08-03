#import "Constants.h"

NSString * const HeadshotAPIBaseURLString = @"http://api.badge.co/v1/";
NSString * const StagingAPIBaseURLString  = @"http://api.badge-staging.com/v1";
NSString * const ProductionMessageServerURLString = @"messaging.badge.co";
NSString * const StagingMessageServerURLString = @"badge-messaging-staging.herokuapp.com";

ServerEnvironment CurrentServerEnvironment = ServerEnvironmentProduction;

NSString * const kReceivedNewMessageNotification = @"ReceivedNewMessageNotification";
NSString * const kRequestAuthorizationErrorNotification = @"RequestAuthorizationNotification";
NSString * const kMessageFailedNotification = @"MessageFailedNotification";
NSString * const kMessageSentNotification = @"MessageSentNotification";
NSString * const kHasStoredCompanyNotification = @"HasStoredCompany";
NSString * const kUserLogginInNotification = @"UserLoggiedIn";

NSString * const kUserDefaultsHasRequestedLocationPermission = @"HasRequestedLocationPermission";
NSString * const kUserDefaultsHasRequestedPushPermission = @"HasRequestedPushPermission";
NSString * const kUserDefaultsLoggedIn = @"UserDefaultsLoggedIn";
NSString * const kUserDefaultsHasFinishedOnboarding = @"HasFinishedOnboarding";
NSString * const kUserDefaultsDeviceIdentifier = @"DeviceIdentifier";

NSString * const kPersistentStoreName = @"Headshot.sqlite";