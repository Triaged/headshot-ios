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

- (void)postDeviceWithCompletion:(void (^)(Device *device, NSError *error))completion
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
    __weak Device *weakSelf = self;
    [[HeadshotAPIClient sharedClient] POST:@"devices" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        self.deviceIdentifier = [responseObject valueForKeyPath:@"device.id"];
        [[NSUserDefaults standardUserDefaults] setObject:self.deviceIdentifier forKey:kUserDefaultsDeviceIdentifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (completion) {
            completion(weakSelf, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

@end
