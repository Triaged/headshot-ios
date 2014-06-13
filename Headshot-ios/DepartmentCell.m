//
//  DepartmentCell.m
//  Headshot-ios
//
//  Created by Charlie White on 6/12/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "DepartmentCell.h"

@implementation DepartmentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _nameLabel = [[UILabel alloc] initWithFrame: CGRectMake(5, 12.5, 200, 30)];
        [_nameLabel setFont: [UIFont fontWithName:@"Whitney-Medium" size:18.0]];
        _nameLabel.textColor = [[UIColor alloc] initWithRed:38.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
        [_nameLabel setLineBreakMode: NSLineBreakByClipping];
        _nameLabel.numberOfLines = 1;
        [self.contentView addSubview: _nameLabel];
        
        _countLabel = [[UILabel alloc] initWithFrame: CGRectMake(280, 12.5, 30, 30)];
        [_countLabel setFont: [UIFont fontWithName:@"Whitney-Medium" size:17.0]];
        _countLabel.textColor = [[UIColor alloc] initWithRed:119.0f/255.0f green:119.0f/255.0f blue:119.0f/255.0f alpha:1.0f];
        [_countLabel setLineBreakMode: NSLineBreakByClipping];
        _countLabel.numberOfLines = 1;
        [self.contentView addSubview: _countLabel];

        
        
    }
    return self;
}

- (void)configureForDepartment:(Department *)department {
    _nameLabel.text = department.name;
    _countLabel.text = [NSString stringWithFormat:@"%@", department.userCount];
}

@end
