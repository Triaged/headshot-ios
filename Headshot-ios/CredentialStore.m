//
//  CredentialStore.m
//  Docked-ios
//
//  Created by Charlie White on 9/21/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import "CredentialStore.h"

#import "CredentialStore.h"
#import "SSKeychain.h"

#define SERVICE_NAME @"Triage-AuthClient"
#define AUTH_TOKEN_KEY @"auth_token"

@implementation CredentialStore

+ (instancetype)sharedStore {
    static CredentialStore *_sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedStore = [[CredentialStore alloc] init];
    });
    
    return _sharedStore;
}

- (BOOL)isLoggedIn {
    NSLog(@"%@", [self authToken]);
    BOOL isLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsLoggedIn];
    BOOL hasAuthToken = self.authToken != nil;
    return isLoggedIn && hasAuthToken;
}

- (void)clearSavedCredentials {
    [self setAuthToken:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"signout" object:self];
}

- (NSString *)authToken {
    return [self secureValueForKey:AUTH_TOKEN_KEY];
}

- (void)setAuthToken:(NSString *)authToken {
    [SSKeychain setAccessibilityType:kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly];
    [self setSecureValue:authToken forKey:AUTH_TOKEN_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"token-changed" object:self];
}

- (void)setSecureValue:(NSString *)value forKey:(NSString *)key {
    if (value) {
        [SSKeychain setPassword:value
                     forService:SERVICE_NAME
                        account:key];
    } else {
        [SSKeychain deletePasswordForService:SERVICE_NAME account:key];
    }
}

- (NSString *)secureValueForKey:(NSString *)key {
    NSError *error = nil;
    NSString *result = [SSKeychain passwordForService:SERVICE_NAME account:key error:&error];
    
    if ([error code] == errSecItemNotFound) {
        NSLog(@"Password not found");
    } else if (error != nil) {
        NSLog(@"Some other error occurred: %@", [error localizedDescription]);
    }
    
    return result;
}

@end
