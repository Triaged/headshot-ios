#import "Constants.h"

NSString * const HeadshotAPIBaseURLString = @"http://api.badge.co/v1/";
NSString * const StagingAPIBaseURLString  = @"http://api.badge-staging.com/v1";
NSString * const SinchProductionAppKey = @"42c9fd75-a981-4d9e-ba79-1c7647df9553";
NSString * const SinchProductionAppSecret = @"wbnKEXplqUWSDMceOSd4hg==";
NSString * const SinchProdunctionEnvironmentHost = @"sandbox.sinch.com";
NSString * const SinchStagingAppKey = @"61dd2830-a808-41a5-9b26-8acd1cd4eece";
NSString * const SinchStagingAppSecret = @"T0arFY+PRUClndBgjLpQlA==";
NSString * const SinchStagingEnvironmentHost = @"sandbox.sinch.com";

ServerEnvironment CurrentServerEnvironment = ServerEnvironmentStaging;

NSString * const kReceivedNewMessageNotification = @"ReceivedNewMessageNotification";

NSString * const kMessageFailedNotification = @"MessageFailedNotification";
NSString * const kMessageSentNotification = @"MessageSentNotification";
NSString * const kHasStoredCompanyNotification = @"HasStoredCompany";

NSString * const kUserDefaultsHasRequestedLocationPermission = @"HasRequestedLocationPermission";
NSString * const kUserDefaultsHasRequestedPushPermission = @"HasRequestedPushPermission";
NSString * const kUserDefaultsLoggedIn = @"UserDefaultsLoggedIn";
NSString * const kUserDefaultsHasFinishedOnboarding = @"HasFinishedOnboarding";
NSString * const kUserDefaultsDeviceIdentifier = @"DeviceIdentifier";

NSString * const kPersistentStoreName = @"Headshot.sqlite";