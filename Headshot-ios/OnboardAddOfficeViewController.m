//
//  OnboardAddOfficeViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OnboardAddOfficeViewController.h"
#import "FormView.h"

@interface OnboardAddOfficeViewController () <UITextFieldDelegate>

@property (strong, nonatomic) FormView *addressFormView;
@property (strong, nonatomic) MKMapView *mapView;

@end

@implementation OnboardAddOfficeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(addButtonTouched:)];
    
    self.addressFormView = [[FormView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    self.addressFormView.backgroundColor = [UIColor whiteColor];
    self.addressFormView.fieldName = @"Address:";
    self.addressFormView.textField.delegate = self;
    [self.addressFormView addEdge:(UIRectEdgeTop | UIRectEdgeBottom) width:0.5 color:[UIColor colorWithWhite:219/255.0 alpha:1.0]];
    [self.view addSubview:self.addressFormView];
    
    self.mapView = [[MKMapView alloc] init];
    self.mapView.size = CGSizeMake(self.view.width, self.view.height - self.addressFormView.height);
    self.mapView.y = self.addressFormView.bottom;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.addressFormView becomeFirstResponder];
}

- (void)addButtonTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
