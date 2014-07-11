//
//  Geofencer.m
//  Headshot-ios
//
//  Created by Charlie White on 5/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "LocationClient.h"
#import "OfficeLocation.h"
#import "FileLogManager.h"

typedef void (^LocationPermissionRequestBlock)(CLAuthorizationStatus);

@interface LocationClient()

@property (strong, nonatomic) LocationPermissionRequestBlock locationPermissionRequestBlock;

@end

@implementation LocationClient

+ (instancetype)sharedClient {
    static LocationClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[LocationClient alloc] init];
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
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsHasRequestedLocationPermission]) {
            User *user = [AppDelegate sharedDelegate].store.currentAccount.currentUser;
            if (user && user.sharingOfficeLocation) {
                [self startMonitoringOffices];
            }
        }
    }
    return self;
}

- (void)requestLocationPermissions:(void (^)(CLAuthorizationStatus authorizationStatus))response
{
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        self.locationPermissionRequestBlock = response;
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
    else {
        response(authorizationStatus);
    }
}

- (void)stopMonitoringOffices
{
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region];
    }
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)startMonitoringOffices
{
    DDLogInfo(@"retreiving offices");
    [OfficeLocation officeLocationsWithCompletionHandler:^(NSArray *locations, NSError *error) {
        NSInteger count = locations && locations.count ? locations.count : 0;
        DDLogInfo(@"retrieved %d offices", count);
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
                                                                              radius:100.0
                                                                          identifier:location.identifier];
                // Start Monitoring Region
                [self.locationManager startMonitoringForRegion:region];
                DDLogInfo(@"started monitoring location with identifier %@", location.identifier);
                [self.locationManager requestStateForRegion:region];
                
            }
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    DDLogInfo(@"did change authorization status to %@", @(status));
    if (self.locationPermissionRequestBlock) {
        self.locationPermissionRequestBlock(status);
        self.locationPermissionRequestBlock = nil;
    }
//    change location permission
    jadispatch_main_qeue(^{
        User *user = [AppDelegate sharedDelegate].store.currentAccount.currentUser;
        NSNumber *currentLocationPermission = user.sharingOfficeLocation;
        user.sharingOfficeLocation = @((status == kCLAuthorizationStatusAuthorized) && currentLocationPermission.boolValue);
        if (!currentLocationPermission || ![user.sharingOfficeLocation isEqualToNumber:currentLocationPermission]) {
            [[AppDelegate sharedDelegate].store.currentAccount updateAccountWithSuccess:nil failure:nil];
        }
    });
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    DDLogInfo(@"Did determine state %@ for region with identifier %@", @(state), region.identifier);
    if (state == CLRegionStateInside) {
        OfficeLocation *location = [self officeLocationForRegion:region];
        [location enterLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    DDLogInfo(@"Did exit region with identifier %@", region.identifier);
    OfficeLocation *location = [self officeLocationForRegion:region];
    [location exitLocation];
}

- (OfficeLocation *)officeLocationForRegion:(CLRegion *)region
{
    return [OfficeLocation MR_findFirstByAttribute:@"identifier" withValue:region.identifier];
}

@end
