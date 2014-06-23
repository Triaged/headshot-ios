//
//  AccountViewController.h
//  Headshot-ios
//
//  Created by Charlie White on 5/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface AccountViewController : UIViewController
@property (strong, nonatomic)  User *currentUser;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentOfficeLocationLabel;
@property (strong, nonatomic) IBOutlet UITableView *contactDetailsTableView;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *tableHeightConstraint;


@end
