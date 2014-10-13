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
@property (strong, nonatomic) UIView *avatarContainerView;
@property (strong, nonatomic) UIImageView *mutedImageView;
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
    self.textFont = [ThemeManager regularFontOfSize:16.0];
    self.unreadTextFont = [ThemeManager regularFontOfSize:16.0];
    self.detailTextFont = [ThemeManager regularFontOfSize:15.0];
    self.unreadDetailTextFont = [ThemeManager regularFontOfSize:15.0];
    self.textColor = [[ThemeManager sharedTheme] darkGrayTextColor];
    self.unreadTextColor = [[ThemeManager sharedTheme] primaryColor];
    self.detailTextColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    self.unreadDetailTextColor = [[ThemeManager sharedTheme] lightGrayTextColor];

    self.detailTextLabel.numberOfLines = 2;
    self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.size = CGSizeMake(100, 31);
    self.timeLabel.right = self.contentView.width -  10;
    self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.timeLabel.font = [ThemeManager regularFontOfSize:11];
    self.timeLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.timeLabel];
    
    UIImage *muteImage = [UIImage imageNamed:@"messages-muted"];
    self.mutedImageView = [[UIImageView alloc] initWithImage:muteImage];
    [self.contentView addSubview:self.mutedImageView];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.avatarContainerView.x = 15;
    self.avatarContainerView.size = CGSizeMake(50, 50);
    self.avatarContainerView.centerY = self.height/2.0;
    self.textLabel.x = self.avatarContainerView.right + 15;
    self.textLabel.width = self.contentView.width - self.textLabel.x - 60;
    self.detailTextLabel.x = self.textLabel.x;
    self.detailTextLabel.width = self.contentView.width - self.detailTextLabel.x - 15;
    
    self.mutedImageView.right = self.timeLabel.right;
    self.mutedImageView.bottom = self.contentView.height - 8;
}

- (void)setMessageThread:(MessageThread *)messageThread
{
    _messageThread = messageThread;
    Message *lastMessage = messageThread.lastMessage;
    if (messageThread.name) {
        self.textLabel.text  = messageThread.name;
    }
    else {
        self.textLabel.text = messageThread.defaultTitle;
    }
    self.detailTextLabel.text = lastMessage.messageText;
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
    if (self.avatarContainerView) {
        [self.avatarContainerView removeFromSuperview];
    }
    self.avatarContainerView = [self avatarContainerViewForRecipients:messageThread.recipientsExcludeUser];
    [self.contentView addSubview:self.avatarContainerView];
    
    self.mutedImageView.hidden = !messageThread.muted.boolValue;
}

- (UIView *)avatarContainerViewForRecipients:(NSSet *)recipients
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    CGSize avatarSize = CGSizeMake(50, 50);
    NSInteger numberOfShownAvatars = 0;
    if (recipients.count == 1) {
        numberOfShownAvatars = 1;
    }
    else if (recipients.count == 2) {
        avatarSize = CGSizeMake(34, 34);
        numberOfShownAvatars = 2;
    }
    else if (recipients.count == 3 || recipients.count > 4) {
        avatarSize = CGSizeMake(25, 25);
        numberOfShownAvatars = 3;
    }
    else if (recipients.count == 4) {
        avatarSize = CGSizeMake(25, 25);
        numberOfShownAvatars = 4;
    }
    NSMutableArray *avatarImageViews = [[NSMutableArray alloc] init];
    NSArray *recipientArray = recipients.allObjects;
    for (NSInteger i=0; i<numberOfShownAvatars; i++) {
        User *user = recipientArray[i];
        TRAvatarImageView *avatarImageView = [[TRAvatarImageView alloc] init];
        avatarImageView.size = avatarSize;
        avatarImageView.user = user;
        [avatarImageViews addObject:avatarImageView];
    }
    if (recipients.count > 4) {
        UILabel *moreRecipientsView = [[UILabel alloc] init];
        moreRecipientsView.size = avatarSize;
        moreRecipientsView.backgroundColor = [UIColor colorWithRed:202/255.0 green:204/255.0 blue:209/255.0 alpha:1.0];
        moreRecipientsView.text = [NSString stringWithFormat:@"+%d", recipients.count - 3];
        moreRecipientsView.textAlignment = NSTextAlignmentCenter;
        moreRecipientsView.font = [ThemeManager regularFontOfSize:11];
        moreRecipientsView.textColor = [UIColor whiteColor];
        [avatarImageViews addObject:moreRecipientsView];
    }
    for (UIView *avatarView in avatarImageViews) {
        avatarView.layer.cornerRadius = avatarView.size.width/2.0;
        avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
        avatarView.layer.borderWidth = 1;
        avatarView.clipsToBounds = YES;
        [view addSubview:avatarView];
    }
    if (recipients.count == 2) {
        UIView *avatar1 = avatarImageViews[0];
        UIView *avatar2 = avatarImageViews[1];
        avatar1.x = 19;
        avatar2.bottom = view.height;
    }
    else if (recipients.count == 3) {
        UIView *avatar1 = avatarImageViews[0];
        UIView *avatar2 = avatarImageViews[1];
        UIView *avatar3 = avatarImageViews[2];
        avatar1.bottom = view.height;
        avatar3.bottom = avatar1.bottom;
        avatar3.right = view.width;
        avatar2.centerX = view.width/2.0;
    }
    else if (recipients.count > 3) {
        UIView *avatar2 = avatarImageViews[1];
        UIView *avatar3 = avatarImageViews[2];
        UIView *avatar4 = avatarImageViews[3];
        avatar2.right = view.width;
        avatar3.bottom = view.bottom;
        avatar4.right = avatar2.right;
        avatar4.bottom = avatar3.bottom;
    }
    
    return view;
}

@end
