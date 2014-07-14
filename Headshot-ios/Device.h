//
//  Device.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeadshotAPIClient.h"

@interface Device : NSObject

@property (strong, nonatomic) UIDevice *device;
@property (strong, nonatomic) NSData *deviceToken;

- (id)initWithDevice:(UIDevice *)device token:(NSData *)token;
- (void)postDeviceWithCompletion:(void (^)(Device *device, NSError *error))completion;

@end
