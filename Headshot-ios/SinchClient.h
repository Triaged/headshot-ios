//
//  SinchClient.h
//  Headshot-ios
//
//  Created by Charlie White on 5/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Sinch/Sinch.h>

@interface SinchClient : NSObject <SINClientDelegate, SINMessageClientDelegate>

@property(strong, nonatomic) id<SINClient> client;


- (void)initSinchClientWithUserId:(NSString *)userId;

+ (instancetype)sharedClient;



@end
