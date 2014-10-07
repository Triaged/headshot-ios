//
//  MessageCell.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/3/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "NewMessageThreadViewController.h"

@interface GroupedMessageCell : UITableViewCell

+ (CGFloat)desiredHeightForMessages:(NSArray *)messages constrainedToSize:(CGSize)size messageTextInsets:(UIEdgeInsets)insets;

@property (weak, nonatomic) id<MessageCellDelegate> messageCellDelegate;
@property (strong, nonatomic) NSArray *messages;
@property (assign, nonatomic) UIEdgeInsets messageTextInsets;

@end
