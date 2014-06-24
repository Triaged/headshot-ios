//
//  OnboardAddOfficeViewController.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;
#import "OfficeLocation.h"

@class AddOfficeViewController;
@protocol AddOfficeViewControllerDelegate <NSObject>

- (void)addOfficeViewController:(AddOfficeViewController *)addOfficeViewController didAddOffice:(OfficeLocation *)office;
- (void)didCancelOfficeViewController:(AddOfficeViewController *)addOfficeViewController;

@end

@interface AddOfficeViewController : UIViewController

@property (weak, nonatomic) id<AddOfficeViewControllerDelegate>delegate;

@end
