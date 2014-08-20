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
#import "User.h"

typedef void (^LocationPermissionRequestBlock)(CLAuthorizationStatus);
static const CLLocationDistance kOfficeRadius = 500;

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
            if (user && user.sharingOfficeLocation.boolValue) {
                [self startMonitoringOffices];
            }
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    }
    return self;
}

- (void)receivedApplicationDidBecomeActiveNotification:(NSNotification *)notification
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        [self updateOfficeStatus];
    }
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

- (void)updateOfficeStatus
{
    DDLogInfo(@"Checking if in office");
    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyHouse timeout:3 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        DDLogInfo(@"Finished location request with status %d", status);
        NSError *error;
        NSMutableArray *inside = [[NSMutableArray alloc] init];
        NSMutableArray *outside = [[NSMutableArray alloc] init];
        if (currentLocation) {
            for (OfficeLocation *office in [OfficeLocation MR_findAll]) {
                CLLocationDistance distance = [office.location distanceFromLocation:currentLocation];
                if (distance > kOfficeRadius) {
                    [outside addObject:office];
                }
                else {
                    [inside addObject:office];
                }
            }
            if (inside.count) {
                OfficeLocation *office = [inside firstObject];
                [office enterLocation];
            }
            else {
                User *user = [AppDelegate sharedDelegate].store.currentAccount.currentUser;
                if (user.currentOfficeLocation) {
                    for (OfficeLocation *office in outside) {
                        if ([office.identifier isEqualToString:user.currentOfficeLocation.identifier]) {
                            [office exitLocation];
                        }
                    }
                }
            }
        }
        else {
            error = [[NSError alloc] initWithDomain:@"TRLocationDomain" code:status userInfo:nil];
        }
    }];
}

- (void)startMonitoringOffices
{
    DDLogInfo(@"retreiving offices");
    [OfficeLocation officeLocationsWithCompletionHandler:^(NSArray *locations, NSError *error) {
        NSInteger count = locations && locations.count ? locations.count : 0;
        DDLogInfo(@"retrieved %d offices", count);
        for (OfficeLocation *location in locations) {
            
            CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake([location.latitude doubleValue], [location.longitude doubleValue]);
            
            CLCircularRegion *region =  [[CLCircularRegion alloc] initWithCenter:centerCoordinate
                                                                          radius:kOfficeRadius
                                                                      identifier:location.identifier];
            // Start Monitoring Region
            [self.locationManager startMonitoringForRegion:region];
            DDLogInfo(@"started monitoring location with identifier %@", location.identifier);
        }
        [self updateOfficeStatus];
    }];
}



- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    DDLogInfo(@"did change authorization status to %@", @(status));
    if (status == kCLAuthorizationStatusNotDetermined) {
        return;
    }
    
    //    change location permission
    User *user = [AppDelegate sharedDelegate].store.currentAccount.currentUser;
    NSNumber *currentLocationPermission = user.sharingOfficeLocation;
    BOOL firstLocationPermissionRequest = ![[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsHasRequestedLocationPermission];
    if (firstLocationPermissionRequest) {
        user.sharingOfficeLocation = @(status == kCLAuthorizationStatusAuthorized);
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsHasRequestedLocationPermission];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
//        sharingOfficeLocation could be NO if user toggles off location permissions in app or denies system location permissions
        BOOL deniedOfficeLocationPermission = user.sharingOfficeLocation && !user.sharingOfficeLocation.boolValue;
        user.sharingOfficeLocation = @((status == kCLAuthorizationStatusAuthorized) && !deniedOfficeLocationPermission);
    }
    if (!currentLocationPermission || ![user.sharingOfficeLocation isEqualToNumber:currentLocationPermission]) {
        [[AppDelegate sharedDelegate].store.currentAccount updateAccountWithSuccess:nil failure:nil];
    }
    
    if (self.locationPermissionRequestBlock) {
        self.locationPermissionRequestBlock(status);
        self.locationPermissionRequestBlock = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    DDLogInfo(@"Did determine state %@ for region with identifier %@", @(state), region.identifier);
    OfficeLocation *location = [self officeLocationForRegion:region];
    
    [self determineDistanceFromOffice:location withCompletion:^(CLLocationDistance distance, CLLocation *currentLocation, NSError *error) {
//        verify accuracy of region event. If error retrieving location, trust region event
        CLRegionState verifiedState = state;
        if (!error) {
            static const CLLocationDistance buffer = 200;
            if (abs(distance - kOfficeRadius) > buffer) {
                verifiedState = distance < kOfficeRadius ? CLRegionStateInside : CLRegionStateOutside;
                DDLogInfo(@"Changed region state from %d to %d", state, verifiedState);
            }
        }
        if (verifiedState == CLRegionStateInside) {
            [location enterLocation];
        }
        else if (verifiedState == CLRegionStateOutside) {
            [location exitLocation];
        }
    }];
}

- (OfficeLocation *)officeLocationForRegion:(CLRegion *)region
{
    return [OfficeLocation MR_findFirstByAttribute:@"identifier" withValue:region.identifier];
}

- (void)determineDistanceFromOffice:(OfficeLocation *)officeLocation withCompletion:(void (^)(CLLocationDistance distance, CLLocation *currentLocation, NSError *error))completion
{
    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyHouse timeout:5 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        DDLogInfo(@"Finished location request with status %d", status);
        CLLocationDistance distance = -1.0;
        NSError *error;
        if (currentLocation) {
            DDLogInfo(@"Current Location %@", currentLocation);
            distance = [currentLocation distanceFromLocation:officeLocation.location];
            DDLogInfo(@"Distance from office %f", distance);
        }
        else {
            error = [[NSError alloc] initWithDomain:@"TRLocationDomain" code:status userInfo:nil];
        }
        if (completion) {
            completion(distance, currentLocation, error);
        }
    }];
}

@end
