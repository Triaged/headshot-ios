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
#import "MessageThread.h"
#import "ReadReceipt.h"

static CGFloat kHeaderHeight = 51;

@interface MessageCell()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) UILabel *readReceiptLabel;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UILabel *messageTextLabel;
@property (strong, nonatomic) UIColor *lightGrayColor;

@end

@implementation MessageCell

+ (CGFloat)desiredHeightForMessage:(Message *)message font:(UIFont *)font constrainedToSize:(CGSize)size textEdgeInsets:(UIEdgeInsets)edgeInsets
{
    CGSize textSize = CGSizeMake(size.width - edgeInsets.right - edgeInsets.left, size.height - edgeInsets.top - edgeInsets.bottom);
    return kHeaderHeight + [self heightForText:message.messageText withFont:font constrainedToSize:textSize] + edgeInsets.top + edgeInsets.bottom;
}

+ (CGFloat)heightForText:(NSString *)text withFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    CGFloat height = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size.height;
    return height;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.headerView = [[UIView alloc] init];
    [self.contentView addSubview:self.headerView];
    self.headerView.width = self.contentView.width;
    self.headerView.height = kHeaderHeight;
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.headerView.backgroundColor = [UIColor whiteColor];
    
    self.avatarImageView = [[TRAvatarImageView alloc] init];
    [self.headerView addSubview:self.avatarImageView];
    
    self.messageTextLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.messageTextLabel];
    self.messageTextLabel.y = self.headerView.bottom;
    self.messageTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.messageTextLabel.numberOfLines = 0;
    
    self.nameLabel = [[UILabel alloc] init];
    [self.headerView addSubview:self.nameLabel];
    self.nameLabel.font = [ThemeManager regularFontOfSize:13];
    self.nameLabel.textColor = [UIColor blackColor];
    
    self.lightGrayColor = [UIColor colorWithRed:202/255.0 green:204/255.0 blue:209/255.0 alpha:1.0];
    
    self.infoLabel = [[UILabel alloc] init];
    [self.headerView addSubview:self.infoLabel];
    self.infoLabel.font = [ThemeManager regularFontOfSize:12];
    self.infoLabel.textColor = self.lightGrayColor;
    
    return self;
}

- (void)setMessage:(Message *)message
{
    _message = message;
    self.avatarImageView.user = message.author;
    self.nameLabel.attributedText = [self.messageCellDelegate attributedNameStringForMessage:message];
    self.messageTextLabel.text = message.messageText;
    self.infoLabel.text = [MessageCell infoTextForMessage:message];

    self.messageTextLabel.textColor = [self.messageCellDelegate textColorForMessage:message];
    self.messageTextLabel.font = [self.messageCellDelegate fontForMessage:message];
}

+ (NSString *)infoTextForMessage:(Message *)message
{
    NSString *infoText;
    NSString *timestampText =  [message.timestamp timeAgoWithLimit:60*60*24 dateFormat:NSDateFormatterMediumStyle andTimeFormat:NSDateFormatterNoStyle];
    CGFloat recipientsCount = message.messageThread.recipients.count;
    NSString *readReceiptText;
    if (recipientsCount > 2) {
        readReceiptText = [NSString stringWithFormat:@"Read by %@/%@", @(message.readRecieptsExcludeAuthor.count), @(message.messageThread.recipients.count - 1)];
        infoText = [NSString stringWithFormat:@"%@, %@", timestampText, readReceiptText];
    }
    else {
        NSMutableSet *receipts = [NSMutableSet setWithSet:message.readRecieptsExcludeAuthor];
        ReadReceipt *receipt = [receipts anyObject];
        if (receipt && ![receipt.user.identifier isEqualToString:[User currentUser].identifier]) {
            readReceiptText = [NSString stringWithFormat:@"Read by %@", receipt.user.firstName];
            infoText = [NSString stringWithFormat:@"%@, %@", timestampText, readReceiptText];
        }
        else {
            infoText = timestampText;
        }
    }
    return infoText;
}

- (void)setShowAvatar:(BOOL)showAvatar
{
    _showAvatar = showAvatar;

    self.avatarImageView.hidden = !showAvatar;
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
    [super layoutSubviews];
    UIEdgeInsets insets = [self.messageCellDelegate contentInsetsForMessage:self.message];
    self.messageTextLabel.x = insets.left;
    self.messageTextLabel.width = self.contentView.width - insets.right - insets.left;
    [self.messageTextLabel sizeToFit];
    self.messageTextLabel.y = self.headerView.bottom + insets.top;
    
    self.avatarImageView.size = CGSizeMake(35, 35);
    self.avatarImageView.x = 12;
    self.avatarImageView.bottom = self.headerView.height;
    
    
    [self.nameLabel sizeToFit];
    self.nameLabel.x = insets.left;
    self.nameLabel.bottom = self.avatarImageView.centerY;
    [self.infoLabel sizeToFit];
    self.infoLabel.x = self.nameLabel.x;
    self.infoLabel.y = self.nameLabel.bottom;
}


@end
