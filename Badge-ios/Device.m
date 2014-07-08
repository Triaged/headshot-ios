//
//  Device.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "Device.h"

@implementation Device

- (id)initWithDevice:(UIDevice *)device token:(NSData *)token
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.device = device;
    self.deviceToken = token;
    return self;
}

- (void)postDeviceWithSuccess:(void (^)(Device *device))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary *deviceJSON = [[NSMutableDictionary alloc] init];
    deviceJSON[@"os_version"] = self.device.systemVersion;
    deviceJSON[@"service"] = self.device.systemName;
    deviceJSON[@"application_id"] = self.device.identifierForVendor.UUIDString;
    if (self.deviceToken) {
        NSString *tokenString = [[self.deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
        deviceJSON[@"token"] = tokenString;
    }
    NSDictionary *parameters = @{@"device" : deviceJSON};
    [[BadgeRequestAPIClient sharedClient] POST:@"devices" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __weak Device *weakSelf = self;
        if (success) {
            success(weakSelf);
        }
    } failure:failure];
}

@end
