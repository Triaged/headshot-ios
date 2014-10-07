//
//  MessageCell.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/3/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRAvatarImageView.h"
#import "Message.h"
#import "NewMessageThreadViewController.h"



@interface MessageCell : UITableViewCell

+ (CGFloat)desiredHeightForMessage:(Message *)message font:(UIFont *)font constrainedToSize:(CGSize)size textEdgeInsets:(UIEdgeInsets)edgeInsets showAvatar:(BOOL)showAvatar;

@property (weak, nonatomic) id<MessageCellDelegate> messageCellDelegate;
@property (strong, nonatomic) TRAvatarImageView *avatarImageView;
@property (assign, nonatomic) BOOL showAvatar;
@property (strong, nonatomic) Message *message;
@property (strong, nonatomic) UIFont *messageTextFont;
@property (strong, nonatomic) UIColor *bubbleBackgroundColor;
@property (assign, nonatomic) UIEdgeInsets messageTextInsets;

@end
