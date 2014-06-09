//
//  TeammateCell.m
//  Docked-ios
//
//  Created by Charlie White on 10/16/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import "ContactCell.h"
#import "UIImageView+AFNetworking.h"
#import "EmployeeInfo.h"

@implementation ContactCell

@synthesize nameLabel, avatarView, titleLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.separatorInset = UIEdgeInsetsMake(0, 70, 0, 0);
        
        // Avatar image
        avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7.5, 40, 40)];
        [self.contentView addSubview: avatarView];
        
        nameLabel = [[UILabel alloc] initWithFrame: CGRectMake(70, 5, 200, 30)];
        [nameLabel setFont: [UIFont fontWithName:@"Whitney-Medium" size:18.0]];
        nameLabel.textColor = [[UIColor alloc] initWithRed:38.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
        [nameLabel setLineBreakMode: NSLineBreakByClipping];
        nameLabel.numberOfLines = 1;
        [self.contentView addSubview: nameLabel];
        
        titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(70, 22, 200, 30)];
        [titleLabel setFont: [UIFont fontWithName:@"Whitney-Medium" size:12.0]];
        titleLabel.textColor = [[UIColor alloc] initWithRed:119.0f/255.0f green:119.0f/255.0f blue:119.0f/255.0f alpha:1.0f];
        [titleLabel setLineBreakMode: NSLineBreakByClipping];
        titleLabel.numberOfLines = 1;
        [self.contentView addSubview: titleLabel];

    }
    return self;
}

-(void) layoutSubviews {
    [super layoutSubviews];
    
}

- (void)configureForUser:(User *)user {
    
    nameLabel.text = user.name;
    titleLabel.text = user.employeeInfo.jobTitle;
    NSURL *avatarUrl = [NSURL URLWithString:user.avatarFaceUrl];
    [avatarView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"avatar"]];


}





@end
