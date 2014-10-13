//
//  ProfileViewController.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/13/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileViewController : UIViewController

@property (strong, nonatomic) User *user;

- (instancetype)initWithUser:(User *)user;

@end
