//
//  AnalyticsManager.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/2/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnalyticsManager : NSObject

+ (instancetype)sharedManager;

- (void)setupForUser;
- (void)updateSuperProperties;

- (void)login;
- (void)logout;
- (void)appForeground;
- (void)managerTapped:(NSString *)managerIdentifier;
- (void)subordinateTapped:(NSString *)subordinateIdentifier;
- (void)messageSentToRecipient:(NSString *)recipientIdentifier;
- (void)profileViewed:(NSString *)profileIdentifier;
- (void)profileButtonTouched:(NSString *)buttonDescription;

@end
