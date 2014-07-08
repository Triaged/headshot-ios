//
//  Device.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BadgeRequestAPIClient.h"

@interface Device : NSObject

@property (strong, nonatomic) UIDevice *device;
@property (strong, nonatomic) NSData *deviceToken;

- (id)initWithDevice:(UIDevice *)device token:(NSData *)token;
- (void)postDeviceWithSuccess:(void (^)(Device *device))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
