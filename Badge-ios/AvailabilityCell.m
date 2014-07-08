//
//  AvailabilityCell.m
//  Headshot-ios
//
//  Created by Charlie White on 6/30/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "AvailabilityCell.h"

@interface AvailabilityCell()

@property (strong, nonatomic) UIImageView *iconImageView;

@end

@implementation AvailabilityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 21, 30)];
    [self.contentView addSubview:self.iconImageView];
    self.textLabel.font = [ThemeManager regularFontOfSize:18];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.iconImageView.size = CGSizeMake(21, 30);
    self.iconImageView.x = 23.5;
    self.iconImageView.centerY = self.height/2.0;
    self.textLabel.x = self.iconImageView.right + 23.5;
}

-(void) setOfficeLocation:(OfficeLocation *)officeLocation {
    _officeLocation = officeLocation;
    if (_officeLocation != [NSNull null]) {
        self.iconImageView.image = [UIImage imageNamed:@"profile-at-office"];
        self.textLabel.textColor = [[ThemeManager sharedTheme] greenColor];
        self.textLabel.text = _officeLocation.name;
    } else {
        self.iconImageView.image = [UIImage imageNamed:@"profile-out-office"];
        self.textLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
        self.textLabel.text = @"Out of office";
    }
}

@end
