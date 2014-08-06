//
//  CredentialStore.h
//  Docked-ios
//
//  Created by Charlie White on 9/21/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CredentialStore : NSObject

- (BOOL)isLoggedIn;
- (void)clearSavedCredentials;
- (NSString *)authToken;
- (void)setAuthToken:(NSString *)authToken;

+ (instancetype)sharedStore;

@end
