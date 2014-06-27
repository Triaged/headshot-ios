//
//  TeammateCell.h
//  Docked-ios
//
//  Created by Charlie White on 10/16/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ContactCell : UITableViewCell

@property (strong, nonatomic) User *user;

-(void)displayCustomSeparator;

@end
