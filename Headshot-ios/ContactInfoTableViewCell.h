//
//  ContactInfoTableViewCell.h
//  Headshot-ios
//
//  Created by Charlie White on 6/11/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCCopyableLabel.h"

@interface ContactInfoTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet TCCopyableLabel *valueLabel;

- (void)configureForLabel:(NSString *)label andValue:(NSString *)value;

@end
