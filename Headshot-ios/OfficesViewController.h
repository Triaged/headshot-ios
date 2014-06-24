//
//  OfficesViewController.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OfficeLocation.h"

@class OfficesViewController;
@protocol OfficesViewControllerDelegate <NSObject>

- (void)didCancelOfficesViewController:(OfficesViewController *)officesViewController;
- (void)officesViewController:(OfficesViewController *)officesViewController didSelectOffice:(OfficeLocation *)office;

@end

@interface OfficesViewController : UITableViewController

@property (strong, nonatomic) NSArray *offices;
@property (weak, nonatomic) id<OfficesViewControllerDelegate> delegate;

@end
