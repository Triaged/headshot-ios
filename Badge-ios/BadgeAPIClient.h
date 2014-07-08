//
//  DockedAPIClient.h
//  Docked-ios
//
//  Created by Charlie White on 9/19/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>

@interface BadgeAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
