//
//  TRBackgroundQueue.m
//  Triage-ios
//
//  Created by Charlie White on 2/10/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "TRBackgroundQueue.h"
#import "CredentialStore.h"

@implementation TRBackgroundQueue

@end

#pragma mark - Singleton implementation

@implementation TRBackgroundQueue (Singleton)

+ (TRBackgroundQueue *)sharedInstance
{
    static TRBackgroundQueue *_instance = nil;
    
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] initWithBaseURL:[NSURL URLWithString:HeadshotAPIBaseURLString]];
    });
    return _instance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
//        self.requestSerializer = [AFJSONRequestSerializer serializer];
//        self.responseSerializer = [AFJSONResponseSerializer serializer];
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

+ (id)allocWithZone:(NSZone *)zone
{
	return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end