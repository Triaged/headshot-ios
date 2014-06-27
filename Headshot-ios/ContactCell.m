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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    self.textLabel.font = [ThemeManager regularFontOfSize:18];
    self.textLabel.textColor = [[ThemeManager sharedTheme] darkGrayTextColor];
    self.detailTextLabel.font = [ThemeManager regularFontOfSize:12];
    self.detailTextLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    
    return self;
}

- (void)setUser:(User *)user
{
    _user = user;
    NSURL *avatarURL = [NSURL URLWithString:user.avatarFaceUrl];
    [self.imageView setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"avatar"]];
    self.textLabel.text = user.fullName;
    self.detailTextLabel.text = user.employeeInfo.jobTitle;
}

-(void)displayCustomSeparator {
    [self addEdge:UIRectEdgeBottom width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.size = CGSizeMake(40, 40);
    self.imageView.centerY = self.height/2.0;
    self.textLabel.x = self.imageView.right + 15;
    self.detailTextLabel.x = self.textLabel.x;
}







@end
