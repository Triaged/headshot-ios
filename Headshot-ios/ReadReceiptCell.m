//
//  ReadReceiptCell.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/10/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "ReadReceiptCell.h"
#import "TRAvatarImageView.h"
#import "User.h"
#import "ReadReceipt.h"

@interface ReadReceiptCell()

@property (strong, nonatomic) TRAvatarImageView *avatarImageView;

@end

@implementation ReadReceiptCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    self.avatarImageView = [[TRAvatarImageView alloc] init];
    [self.contentView addSubview:self.avatarImageView];
    return self;
}

- (void)configureForReadReceipt:(ReadReceipt *)readReceipt
{
    self.avatarImageView.user = readReceipt.user;
    self.textLabel.text = readReceipt.user.fullName;
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.AMSymbol = @"am";
        dateFormatter.PMSymbol = @"pm";
        dateFormatter.dateFormat = @"MMM d, h:mm a";
    });
    self.detailTextLabel.text = [NSString stringWithFormat:@"Read on %@", [dateFormatter stringFromDate:readReceipt.timestamp]];
}

- (void)configureForUnreadUser:(User *)user
{
    self.avatarImageView.user = user;
    self.textLabel.text = user.fullName;
    self.detailTextLabel.text = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.avatarImageView.size = CGSizeMake(40, 40);
    self.avatarImageView.x = 17;
    self.avatarImageView.centerY = self.contentView.height/2.0;
    self.textLabel.x = self.avatarImageView.right + 17;
    self.detailTextLabel.x = self.textLabel.x;
    
    
}



@end
