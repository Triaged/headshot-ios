//
//  DockedRequestAPIClient.h
//  Triage-ios
//
//  Created by Charlie White on 11/4/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface BadgeRequestAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

@end
