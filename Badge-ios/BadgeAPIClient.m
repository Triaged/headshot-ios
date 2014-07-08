//
//  DockedAPIClient.m
//  Docked-ios
//
//  Created by Charlie White on 9/19/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import "BadgeAPIClient.h"
#import "CredentialStore.h"
#import "AppDelegate.h"
#import "Store.h"
#import "TRJSONResponseSerializerWithData.h"

@implementation BadgeAPIClient

+ (instancetype)sharedClient {
    static BadgeAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[BadgeAPIClient alloc] initWithBaseURL:[NSURL URLWithString:HeadshotAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [TRJSONResponseSerializerWithData serializer];
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

- (void)setUploadProgressForTask:(NSURLSessionTask *)task
                      usingBlock:(void (^)(uint32_t bytesWritten, uint32_t totalBytesWritten, uint32_t totalBytesExpectedToWrite))block {
}

@end
