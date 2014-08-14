//
//  AnalyticsManager.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/2/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "AnalyticsManager.h"
#import <Mixpanel/Mixpanel.h>
#import "User.h"

@implementation AnalyticsManager

+ (instancetype)sharedManager
{
    static AnalyticsManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setupForUser];
    }
    return self;
}

- (void)startMixpanel
{
    [Mixpanel sharedInstanceWithToken:[[ConstantsManager sharedConstants] mixpanelToken]];
}

- (void)setupForUser
{
    User *loggedInUser = [AppDelegate sharedDelegate].store.currentAccount.currentUser;
    [self startMixpanel];
    if (!loggedInUser || !loggedInUser.identifier) {
        return;
    }
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:loggedInUser.identifier];
    [self updateSuperProperties];
}

- (void)updateSuperProperties
{
    User *user = [AppDelegate sharedDelegate].store.currentAccount.currentUser;
    if (!user) {
        return;
    }
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    NSMutableArray *mixpanelProperties = [NSMutableArray arrayWithArray:@[@"$email", @"$first_name", @"$last_name"]];
    NSMutableArray *userProperties = [NSMutableArray arrayWithArray:@[@"email", @"firstName", @"lastName"]];
    if (user.company && user.company.name) {
        [mixpanelProperties addObject:@"company_name"];
        [userProperties addObject:@"company.name"];
    }
    if (user.company && user.company.identifier) {
        [mixpanelProperties addObject:@"company_id"];
        [userProperties addObject:@"company.identifier"];
    }
    
    NSMutableDictionary *superProperties = [[NSMutableDictionary alloc] init];
    for (NSInteger i=0; i<mixpanelProperties.count; i++) {
        NSString *keyPath = userProperties[i];
        id value = [user valueForKeyPath:keyPath];
        if (value) {
            [mixpanel.people set:mixpanelProperties[i] to:value];
            [superProperties setObject:value forKey:keyPath];
        }
    }
    [mixpanel registerSuperProperties:superProperties];
}

- (void)sendEvent:(NSString *)event withProperties:(NSDictionary *)properties
{
    if (properties) {
        [[Mixpanel sharedInstance] track: event properties:properties];
    }
    else {
        [[Mixpanel sharedInstance] track: event];
    }
}

- (void)login
{
    [self sendEvent:@"login" withProperties:nil];
}

- (void)logout
{
    [self sendEvent:@"logout" withProperties:nil];
}

- (void)appForeground
{
    [self sendEvent:@"app_foreground" withProperties:nil];
}

- (void)managerTapped:(NSString *)managerIdentifier
{
    NSDictionary *properties = @{@"manager_id" : managerIdentifier};
    [self sendEvent:@"manager_tapped" withProperties:properties];
}

- (void)subordinateTapped:(NSString *)subordinateIdentifier
{
    NSDictionary *properties = @{@"subordinate_id" : subordinateIdentifier};
    [self sendEvent:@"subordinate_tapped" withProperties:properties];
}

- (void)messageSent
{
    [self sendEvent:@"message_sent" withProperties:nil];
}

- (void)profileViewed:(NSString *)profileIdentifier
{
    NSDictionary *properties = @{@"user_id" : profileIdentifier};
    [self sendEvent:@"profile_viewed" withProperties:properties];
}

- (void)profileButtonTouched:(NSString *)buttonDescription
{
    NSDictionary *properties = @{@"button" : buttonDescription};
    [self sendEvent:@"profile_button_touched" withProperties:properties];
}

- (void)avatarUploaded
{
    [self sendEvent:@"avatar_uploaded" withProperties:nil];
}

- (void)locationEnabled
{
    [self sendEvent:@"location_enabled" withProperties:nil];
}

- (void)locationDisabled
{
    [self sendEvent:@"location_disabled" withProperties:nil];
}


- (void)pushEnabled
{
    [self sendEvent:@"push_enabled" withProperties:nil];
}



@end
