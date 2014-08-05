#import "Constants.h"

NSString * const kAPIBaseURLStringProduction = @"https://api.badge.co/v1/";
NSString * const kAPIBaseURLStringStaging  = @"http://api.badge-staging.com/v1";
NSString * const kMessageServerURLStringProduction = @"messaging.badge.co";
NSString * const kMessageServerURLStringStaging = @"badge-messaging-staging.herokuapp.com";

NSString * const kMixpanelTokenProduction = @"ec6f12813c52d6dc6709aab1bf5cb1b9";
NSString * const kMixpanelTokenStaging =  @"b9c753b3560536492eba971a53213f5f";

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


#pragma mark - Production
@interface ProductionConstants : NSObject<Constants>

@end

@implementation ProductionConstants

- (NSString *)APIBaseURLString
{
    return kAPIBaseURLStringProduction;
}

- (NSString *)messageServerURLString
{
    return kMessageServerURLStringProduction;
}

- (NSString *)mixpanelToken
{
    return kMixpanelTokenProduction;
}

@end

#pragma mark - Staging
@interface StagingConstants : NSObject<Constants>

@end

@implementation StagingConstants

- (NSString *)APIBaseURLString
{
    return kAPIBaseURLStringStaging;
}

- (NSString *)messageServerURLString
{
    return kMessageServerURLStringStaging;
}

- (NSString *)mixpanelToken
{
    return kMixpanelTokenStaging;
}

@end

@implementation ConstantsManager

+ (ServerEnvironment)ServerEnvironment
{
    return ServerEnvironmentStaging;
}

+ (id<Constants>)sharedConstants
{
    static id <Constants> sharedConstants = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([self ServerEnvironment] == ServerEnvironmentProduction) {
            sharedConstants = [[StagingConstants alloc] init];
        }
        else  if ([self ServerEnvironment] == ServerEnvironmentStaging) {
            sharedConstants = [[StagingConstants alloc] init];
        }
    });
    
    return sharedConstants;
}

+ (NSString *)APIBaseURLString
{
    return [[self sharedConstants] APIBaseURLString];
}

+ (NSString *)MessageServerURLString
{
    return [[self sharedConstants] messageServerURLString];
}

@end