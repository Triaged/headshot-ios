//
//  MessageThreadPreviewCell.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/16/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "MessageThreadPreviewCell.h"
#import <NSDate+TimeAgo.h>
#import "Message.h"
#import "User.h"
#import "TRAvatarImageView.h"

@interface MessageThreadPreviewCell()

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) TRAvatarImageView *avatarImageView;
@property (strong, nonatomic) UIFont *textFont;
@property (strong, nonatomic) UIFont *unreadTextFont;
@property (strong, nonatomic) UIFont *detailTextFont;
@property (strong, nonatomic) UIFont *unreadDetailTextFont;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIColor *unreadTextColor;
@property (strong, nonatomic) UIColor *detailTextColor;
@property (strong, nonatomic) UIColor *unreadDetailTextColor;

@end

@implementation MessageThreadPreviewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    self.textFont = [ThemeManager regularFontOfSize:15.0];
    self.unreadTextFont = [ThemeManager boldFontOfSize:15.0];
    self.detailTextFont = [ThemeManager regularFontOfSize:12];
    self.unreadDetailTextFont = [ThemeManager boldFontOfSize:12.0];
    self.textColor = [[ThemeManager sharedTheme] orangeColor];
    self.unreadTextColor = [[ThemeManager sharedTheme] orangeColor];
    self.detailTextColor = [[ThemeManager sharedTheme] darkGrayTextColor];
    self.unreadDetailTextColor = [[ThemeManager sharedTheme] darkGrayTextColor];

    self.detailTextLabel.numberOfLines = 3;
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.size = CGSizeMake(100, 31);
    self.timeLabel.right = self.contentView.width -  10;
    self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.timeLabel.font = [ThemeManager regularFontOfSize:9];
    self.timeLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.timeLabel];
    
    self.avatarImageView = [[TRAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.contentView addSubview:self.avatarImageView];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.avatarImageView.x = 15;
    self.avatarImageView.size = CGSizeMake(40, 40);
    self.avatarImageView.centerY = self.height/2.0;
    self.textLabel.x = self.avatarImageView.right + 15;
    self.textLabel.width = self.contentView.width - self.textLabel.x - 15;
    self.detailTextLabel.x = self.textLabel.x;
    self.detailTextLabel.width = self.contentView.width - self.detailTextLabel.x - 15;
}

- (void)setMessageThread:(MessageThread *)messageThread
{
    _messageThread = messageThread;
    if (messageThread.isGroupThread) {
        self.avatarImageView.image = [UIImage imageNamed:@"messages-group"];
    }
    else {
        User *recipient = messageThread.directMessageRecipient;
        self.avatarImageView.user = recipient;
    }
    Message *lastMessage = messageThread.lastMessage;
    self.textLabel.text = messageThread.defaultTitle;
    self.detailTextLabel.text = lastMessage.text;
    self.timeLabel.text = [lastMessage.timestamp timeAgoWithLimit:60*60*24 dateFormat:NSDateFormatterMediumStyle andTimeFormat:NSDateFormatterNoStyle];
    if (messageThread.unread.boolValue) {
        self.textLabel.font = self.unreadTextFont;
        self.detailTextLabel.font = self.unreadDetailTextFont;
        self.textLabel.textColor = self.unreadTextColor;
        self.detailTextLabel.textColor = self.unreadDetailTextColor;
    }
    else {
        self.textLabel.font = self.textFont;
        self.detailTextLabel.font = self.detailTextFont;
        self.textLabel.textColor = self.textColor;
        self.detailTextLabel.textColor = self.detailTextColor;
    }
}

@end
