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
        self.separatorInset = UIEdgeInsetsMake(0, 14, 0, 0);
        
        _nameLabel = [[UILabel alloc] initWithFrame: CGRectMake(14, 0, 200, 55)];
        [_nameLabel setFont: [UIFont fontWithName:@"Whitney-Medium" size:18.0]];
        _nameLabel.textColor = [[UIColor alloc] initWithRed:38.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
        [_nameLabel setLineBreakMode: NSLineBreakByClipping];
        _nameLabel.numberOfLines = 1;
        [self.contentView addSubview: _nameLabel];
        
        self.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 52, 55)];
        
        _countLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 30, 55)];
        [_countLabel setFont: [UIFont fontWithName:@"Whitney-Medium" size:17.0]];
        _countLabel.textColor = [[UIColor alloc] initWithRed:119.0f/255.0f green:119.0f/255.0f blue:119.0f/255.0f alpha:1.0f];
        [_countLabel setLineBreakMode: NSLineBreakByClipping];
        _countLabel.numberOfLines = 1;
        _countLabel.textAlignment = NSTextAlignmentRight;
        [self.accessoryView addSubview: _countLabel];
        
        UIImageView *chevronView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list-chevron"]];
        chevronView.centerY = self.accessoryView.height/2.0;
        chevronView.x = 45;
        [self.accessoryView addSubview: chevronView];

        
        
    }
    return self;
}

- (void)configureForDepartment:(Department *)department {
    _nameLabel.text = department.name;
    _countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)department.users.count];
}

@end
