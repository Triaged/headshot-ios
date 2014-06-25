//
//  OnboardAddOfficeViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "AddOfficeViewController.h"
#import <INTULocationManager.h>
#import "FormView.h"
#import "LocationClient.h"

@interface AddOfficeViewController () <UITextFieldDelegate>

@property (strong, nonatomic) FormView *addressFormView;
@property (strong, nonatomic) FormView *cityFormView;
@property (strong, nonatomic) FormView *stateFormView;
@property (strong, nonatomic) UIView *formContainerView;
@property (strong, nonatomic) UIButton *currentLocationButton;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) OfficeLocation *officeLocation;

@end

@implementation AddOfficeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Add Office";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonTouched:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(addButtonTouched:)];
    
    CGFloat formHeight = 44;
    self.formContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, formHeight*2)];
    self.formContainerView.backgroundColor = [UIColor whiteColor];
    self.formContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;

    [self.view addSubview:self.formContainerView];
    
    self.addressFormView = [[FormView alloc] initWithFrame:CGRectMake(0, 0, self.formContainerView.width, formHeight)];
    self.addressFormView.backgroundColor = [UIColor whiteColor];
    self.addressFormView.fieldName = @"Address:";
    self.addressFormView.textField.delegate = self;
    [self.addressFormView addEdge:(UIRectEdgeTop | UIRectEdgeBottom) width:0.5 color:[UIColor colorWithWhite:219/255.0 alpha:1.0]];
    [self.formContainerView addSubview:self.addressFormView];
    
    self.cityFormView = [[FormView alloc] initWithFrame:CGRectMake(0, self.addressFormView.bottom, 0.6*self.formContainerView.width, formHeight)];
    self.cityFormView.backgroundColor = [UIColor whiteColor];
    self.cityFormView.fieldName = @"City:";
    self.cityFormView.textField.delegate = self;
    [self.cityFormView addEdge:(UIRectEdgeBottom | UIRectEdgeRight) width:0.5 color:[UIColor colorWithWhite:219/255.0 alpha:1.0]];
    [self.formContainerView addSubview:self.cityFormView];
    
    self.stateFormView = [[FormView alloc] initWithFrame:CGRectMake(self.cityFormView.right, self.cityFormView.y, self.formContainerView.width - self.cityFormView.width, formHeight)];
    self.stateFormView.fieldName = @"State:";
    self.stateFormView.textField.delegate = self;
    [self.stateFormView addEdge:UIRectEdgeBottom width:0.5 color:[UIColor colorWithWhite:219/255.0 alpha:1.0]];
    [self.formContainerView addSubview:self.stateFormView];
    
    self.mapView = [[MKMapView alloc] init];
    self.mapView.size = CGSizeMake(self.view.width, self.view.height - self.formContainerView.height);
    self.mapView.y = self.formContainerView.bottom;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    self.currentLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.currentLocationButton.size = CGSizeMake(38, 38);
    self.currentLocationButton.x = 8;
    self.currentLocationButton.y = self.formContainerView.bottom + 8;
    [self.currentLocationButton setImage:[UIImage imageNamed:@"onboarding-icn-map-inactive"] forState:UIControlStateNormal];
    [self.currentLocationButton setImage:[UIImage imageNamed:@"onboarding-icn-map-active"] forState:UIControlStateSelected];
    [self.currentLocationButton addTarget:self action:@selector(currentLocationButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.currentLocationButton];
}

- (void)geocodeLocationFromFields
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    NSDictionary *addressDictionary = @{@"Street" : self.addressFormView.textField.text,
                                        @"State" : self.stateFormView.textField.text,
                                        @"City" : self.cityFormView.textField.text};
    [geoCoder geocodeAddressDictionary:addressDictionary completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count) {
            CLPlacemark *placemark = [placemarks firstObject];
            self.officeLocation = [self officeLocationFromPlacemark:placemark];
        }
    }];
}

- (void)currentLocationButtonTouched:(id)sender
{
    self.currentLocationButton.selected = YES;
    [SVProgressHUD show];
    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyHouse timeout:4 delayUntilAuthorized:YES block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        [SVProgressHUD dismiss];
        if (currentLocation) {
            [self centerOnCoordinate:currentLocation.coordinate];
        }
        self.mapView.showsUserLocation = YES;
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:[LocationClient sharedClient].locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks && placemarks.count) {
                CLPlacemark *placemark = [placemarks firstObject];
                self.officeLocation = [self officeLocationFromPlacemark:placemark];
                [self autoFillFormsWithPlacemark:placemark];
            }
        }];
    }];
}

- (void)centerOnCoordinate:(CLLocationCoordinate2D)coordinate
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 200, 200);
    [self.mapView setRegion:region animated:YES];
}

- (void)autoFillFormsWithPlacemark:(CLPlacemark *)placemark
{
    NSString *city = placemark.addressDictionary[@"City"];
    NSString *state = placemark.addressDictionary[@"State"];
    NSString *address = placemark.addressDictionary[@"Street"];
    self.cityFormView.textField.text = city;
    self.stateFormView.textField.text = state;
    self.addressFormView.textField.text = address;
}

- (OfficeLocation *)officeLocationFromPlacemark:(CLPlacemark *)placemark
{
    OfficeLocation *officeLocation = [OfficeLocation MR_createEntity];
    officeLocation.streetAddress = placemark.addressDictionary[@"Street"];
    officeLocation.zipCode = placemark.addressDictionary[@"ZIP"];
    officeLocation.state = placemark.addressDictionary[@"State"];
    officeLocation.country = placemark.addressDictionary[@"Country"];
    officeLocation.city = placemark.addressDictionary[@"City"];
    return officeLocation;
}

- (OfficeLocation *)officeLocationFromFields
{
    OfficeLocation *officeLocation = [OfficeLocation MR_createEntity];
    officeLocation.streetAddress = self.addressFormView.textField.text;
    officeLocation.city = self.cityFormView.textField.text;
    officeLocation.state = self.stateFormView.textField.text;
    return officeLocation;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.addressFormView becomeFirstResponder];
}

- (void)cancelButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didCancelOfficeViewController:)]) {
        [self.delegate didCancelOfficeViewController:self];
    }
}

- (void)addButtonTouched:(id)sender
{
    if (![self validateFields]) {
        return;
    }
    if (!self.currentLocationButton.selected) {
        self.officeLocation = [self officeLocationFromFields];
    }
    [SVProgressHUD show];
    [self.officeLocation postWithCompletion:^(OfficeLocation *officeLocation, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            if ([self.delegate respondsToSelector:@selector(addOfficeViewController:didAddOffice:)]) {
                [self.delegate addOfficeViewController:self didAddOffice:officeLocation];
            }
        }
    }];
}

- (BOOL)validateFields
{
    BOOL complete = YES;
    for (NSString *text in @[self.addressFormView.textField.text, self.cityFormView.textField.text, self.stateFormView.textField.text]) {
        complete = complete && text && text.length;
    }
    if (!complete) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please fill out the address, city, and state" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    return complete;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
//    make sure all forms have been completed
    BOOL completed = self.cityFormView.textField.text && self.addressFormView.textField.text && self.stateFormView.textField.text;
    if (completed) {
        [self geocodeLocationFromFields];
    }
    
    return YES;
}



@end
