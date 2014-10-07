//
//  MessageCell.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/3/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "MessageCell.h"
#import <NSDate+TimeAgo.h>
#import "User.h"

@interface MessageCell()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *timestampLabel;
@property (strong, nonatomic) UILabel *readReceiptLabel;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UILabel *messageTextLabel;

@end

@implementation MessageCell

+ (CGFloat)desiredHeightForMessage:(Message *)message font:(UIFont *)font constrainedToSize:(CGSize)size textEdgeInsets:(UIEdgeInsets)edgeInsets showAvatar:(BOOL)showAvatar
{
    CGSize textSize = CGSizeMake(size.width - edgeInsets.right - edgeInsets.left, size.height - edgeInsets.top - edgeInsets.bottom);
    return [self headerHeightShowAvatar:showAvatar] + [self heightForText:message.messageText withFont:font constrainedToSize:textSize] + edgeInsets.top + edgeInsets.bottom;
}

+ (CGFloat)headerHeightShowAvatar:(BOOL)showAvatar
{
    return showAvatar ? 45 : 26;
}

+ (CGFloat)heightForText:(NSString *)text withFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    CGFloat height = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size.height;
    return height;
}

- (TRAvatarImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[TRAvatarImageView alloc] init];
        [self.headerView addSubview:_avatarImageView];
    }
    return _avatarImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.headerView = [[UIView alloc] init];
    [self.contentView addSubview:self.headerView];
    self.headerView.width = self.contentView.width;
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.headerView.backgroundColor = [UIColor whiteColor];
    
    self.messageTextLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.messageTextLabel];
    self.messageTextLabel.width = self.contentView.width;
    self.messageTextLabel.y = self.headerView.bottom;
    self.messageTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.messageTextLabel.numberOfLines = 0;
    
    self.nameLabel = [[UILabel alloc] init];
    [self.headerView addSubview:self.nameLabel];
    self.nameLabel.font = [ThemeManager regularFontOfSize:14];
    self.nameLabel.textColor = [UIColor blackColor];
    
    self.timestampLabel = [[UILabel alloc] init];
    [self.headerView addSubview:self.timestampLabel];
    self.timestampLabel.font = [ThemeManager regularFontOfSize:12];
    self.timestampLabel.textColor = [UIColor lightGrayColor];
    
    return self;
}

- (void)setMessage:(Message *)message
{
    _message = message;
    self.avatarImageView.user = message.author;
    self.nameLabel.text = message.author.fullName;
    self.messageTextLabel.text = message.messageText;
    self.timestampLabel.text =  [message.timestamp timeAgoWithLimit:60*60*24 dateFormat:NSDateFormatterMediumStyle andTimeFormat:NSDateFormatterNoStyle];
    self.messageTextLabel.textColor = [self.messageCellDelegate textColorForMessage:message];
}

- (void)setShowAvatar:(BOOL)showAvatar
{
    _showAvatar = showAvatar;

    self.avatarImageView.hidden = !showAvatar;
    self.nameLabel.hidden = !showAvatar;
    self.headerView.height = [MessageCell headerHeightShowAvatar:showAvatar];
}

- (void)setBubbleBackgroundColor:(UIColor *)bubbleBackgroundColor
{
    _bubbleBackgroundColor = bubbleBackgroundColor;
    self.contentView.backgroundColor = bubbleBackgroundColor;
}

- (void)setMessageTextFont:(UIFont *)messageTextFont
{
    _messageTextFont = messageTextFont;
    self.messageTextLabel.font = messageTextFont;
}

- (void)layoutSubviews
{
    self.messageTextLabel.height = [MessageCell heightForText:self.messageTextLabel.text withFont:self.messageTextLabel.font constrainedToSize:CGSizeMake(self.contentView.width, CGFLOAT_MAX)];
    [super layoutSubviews];
    UIEdgeInsets textInsets = [self.messageCellDelegate textInsetsForMessage:self.message];
    self.messageTextLabel.y = self.headerView.bottom + textInsets.top;
    self.messageTextLabel.x = textInsets.left;
    self.avatarImageView.size = CGSizeMake(35, 35);
    self.avatarImageView.x = 10;
    self.avatarImageView.centerY = self.avatarImageView.superview.height/2.0;
    [self.nameLabel sizeToFit];
    self.nameLabel.x = self.avatarImageView.right + 10;
    self.nameLabel.y = self.avatarImageView.y;
    [self.timestampLabel sizeToFit];
    if (self.showAvatar) {
        self.timestampLabel.y = self.nameLabel.bottom;
        self.timestampLabel.x = self.nameLabel.x;
    }
    else {
        self.timestampLabel.centerY = self.timestampLabel.superview.height/2.0;
        self.timestampLabel.x = 10;
    }
}

@end
