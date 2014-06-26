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

@interface MessageThreadPreviewCell()

@property (strong, nonatomic) UILabel *timeLabel;

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
    
    return self;
}

- (void)setMessageThread:(MessageThread *)messageThread
{
    _messageThread = messageThread;
    NSURL *avatarURL = [NSURL URLWithString:messageThread.recipient.avatarFaceUrl];
    [self.imageView setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"avatar"]];
    Message *lastMessage = messageThread.lastMessage;
    self.textLabel.text = messageThread.recipient.fullName;
    self.detailTextLabel.text = lastMessage.text;
    self.timeLabel.text = [lastMessage.timestamp timeAgoWithLimit:60*60*24 dateFormat:NSDateFormatterMediumStyle andTimeFormat:NSDateFormatterNoStyle];
}

@end
