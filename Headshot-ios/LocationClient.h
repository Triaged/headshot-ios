//
//  Geofencer.h
//  Headshot-ios
//
//  Created by Charlie White on 5/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationClient : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

+ (instancetype)sharedClient;

- (void)requestLocationPermissions:(void (^)(CLAuthorizationStatus authorizationStatus))response;

@end
