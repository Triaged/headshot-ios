//
//  Geofencer.m
//  Headshot-ios
//
//  Created by Charlie White on 5/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "Geofencer.h"
#import "OfficeLocation.h"

@implementation Geofencer

+ (instancetype)sharedClient {
    static Geofencer *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[Geofencer alloc] init];
    });
    
    return _sharedClient;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialize Location Manager
        self.locationManager = [[CLLocationManager alloc] init];
        
        // Configure Location Manager
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        
         [self.locationManager startMonitoringSignificantLocationChanges];
    }
    return self;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [OfficeLocation officeLocationsWithCompletionHandler:^(NSArray *locations, NSError *error) {
        
        for (OfficeLocation *location in locations) {
            
            BOOL shouldCreateRegion = YES;
            for (CLCircularRegion *region in self.locationManager.monitoredRegions) {
                if (location.identifier == region.identifier) {
                    shouldCreateRegion = NO;
                }
            }
            
            if (shouldCreateRegion) {
                CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake([location.latitude doubleValue], [location.longitude doubleValue]);

                CLCircularRegion *region =  [[CLCircularRegion alloc] initWithCenter:centerCoordinate
                                                                              radius:kCLLocationAccuracyHundredMeters
                                                                          identifier:location.identifier];
                // Start Monitoring Region
                [self.locationManager startMonitoringForRegion:region];
                [self.locationManager stopUpdatingLocation];
                
            }
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    OfficeLocation *location = [OfficeLocation MR_findFirstByAttribute:@"identifier" withValue:region.identifier];
    [location enterLocation];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    OfficeLocation *location = [OfficeLocation MR_findFirstByAttribute:@"identifier" withValue:region.identifier];
    [location exitLocation];
}

@end
