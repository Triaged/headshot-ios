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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.valueLabel setMinimumPressDuration:1];
    [self addEdge:UIRectEdgeBottom width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureForLabel:(NSString *)label andValue:(NSString *)value {
    self.titleLabel.text = label;
    self.valueLabel.text = value;
}

@end
