//
//  ContactInfoTableViewCell.m
//  Headshot-ios
//
//  Created by Charlie White on 6/11/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "ContactInfoTableViewCell.h"

@implementation ContactInfoTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureForArray:(NSArray *)array {
    self.titleLabel.text = [array firstObject];
    self.valueLabel.text = [array lastObject];
}

@end
