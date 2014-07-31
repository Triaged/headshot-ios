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

@end

@implementation MessageThreadPreviewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    self.textLabel.font = [ThemeManager regularFontOfSize:15.0];
    self.textLabel.textColor = [[ThemeManager sharedTheme] orangeColor];
    self.detailTextLabel.font = [ThemeManager regularFontOfSize:12];
    self.detailTextLabel.textColor = [[ThemeManager sharedTheme] darkGrayTextColor];
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
}

@end
