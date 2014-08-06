//
//  DockedAPIClient.h
//  Docked-ios
//
//  Created by Charlie White on 9/19/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>

@interface HeadshotAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (void)performMultipartFormRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block completion:(void (^)(id responseObject, NSError *error))completion;

@end
