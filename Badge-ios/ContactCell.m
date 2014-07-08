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
#import "TRAvatarImageView.h"

@interface ContactCell()

@property (strong, nonatomic) TRAvatarImageView *avatarImageView;

@end

@implementation ContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    self.avatarImageView = [[TRAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.contentView addSubview:self.avatarImageView];
    self.textLabel.font = [ThemeManager regularFontOfSize:18];
    self.textLabel.textColor = [[ThemeManager sharedTheme] darkGrayTextColor];
    self.detailTextLabel.font = [ThemeManager regularFontOfSize:12];
    self.detailTextLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    
    return self;
}

- (void)setUser:(User *)user
{
    _user = user;
    self.avatarImageView.user = user;
    self.textLabel.text = user.fullName;
    self.detailTextLabel.text = user.employeeInfo.jobTitle;
}

-(void)displayCustomSeparator {
    [self addEdge:UIRectEdgeBottom width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.avatarImageView.size = CGSizeMake(40, 40);
    self.avatarImageView.x = 15;
    self.avatarImageView.centerY = self.height/2.0;
    self.textLabel.x = self.avatarImageView.right + 15;
    self.detailTextLabel.x = self.textLabel.x;
}







@end
