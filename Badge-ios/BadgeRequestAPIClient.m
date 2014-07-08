//
//  DockedRequestAPIClient.m
//  Triage-ios
//
//  Created by Charlie White on 11/4/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import "BadgeRequestAPIClient.h"
#import "CredentialStore.h"

@implementation BadgeRequestAPIClient

+ (instancetype)sharedClient {
    static BadgeRequestAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[BadgeRequestAPIClient alloc] initWithBaseURL:[NSURL URLWithString:HeadshotAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        [self setAuthTokenHeader];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tokenChanged:)
                                                     name:@"token-changed"
                                                   object:nil];
    }
    return self;
}


- (void)setAuthTokenHeader {
    CredentialStore *store = [[CredentialStore alloc] init];
    NSString *authToken = [store authToken];
    [self.requestSerializer setValue:authToken forHTTPHeaderField:@"authorization"];
}

- (void)tokenChanged:(NSNotification *)notification {
    [self setAuthTokenHeader];
}

@end
