//
//  MessageCell.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/3/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "GroupedMessageCell.h"
#import "Message.h"
#import "MessageCell.h"

@interface GroupedMessageCell() <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIFont *messageTextFont;

@end

@implementation GroupedMessageCell

+ (CGFloat)desiredHeightForMessages:(NSArray *)messages constrainedToSize:(CGSize)size messageTextInsets:(UIEdgeInsets)insets
{
    
    CGFloat height = 0;
    BOOL showAvatar = YES;
    for (Message *message in messages) {
//        height += [MessageCell desiredHeightForMessage:message font:[ThemeManager regularFontOfSize:16] constrainedToSize:CGSizeMake(320, CGFLOAT_MAX)
        height += [MessageCell desiredHeightForMessage:message font:[ThemeManager regularFontOfSize:16] constrainedToSize:size textEdgeInsets:insets showAvatar:showAvatar];
        showAvatar = NO;
    }
    return height;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.layer.cornerRadius = 8;
    self.tableView.layer.borderColor = [UIColor colorWithRed:234/255.0 green:235/255.0 blue:236/255.0 alpha:1.0].CGColor;
    self.tableView.layer.borderWidth = 0.5;
    
    return self;
}

- (void)setMessages:(NSArray *)messages
{
    _messages = messages;
    [self.tableView reloadData];
}

- (void)layoutSubviews
{
    self.tableView.width = [self.messageCellDelegate maxCellWidthForMessage:nil];
    self.tableView.x = 15;
    [super layoutSubviews];
}

#pragma mark - messages
- (BOOL)showsAvatarAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == 0;
}

- (Message *)messageForIndexPath:(NSIndexPath *)indexPath
{
    return self.messages[indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self messageForIndexPath:indexPath];
    return [MessageCell desiredHeightForMessage:message font:[self.messageCellDelegate fontForMessage:message]  constrainedToSize:CGSizeMake([self.messageCellDelegate maxCellWidthForMessage:message], CGFLOAT_MAX) textEdgeInsets:[self.messageCellDelegate textInsetsForMessage:message]  showAvatar:[self showsAvatarAtIndexPath:indexPath]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"CellIdentifer";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.messageTextFont = self.messageTextFont;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.messageCellDelegate = self.messageCellDelegate;
    }
    Message *message = [self messageForIndexPath:indexPath];
    cell.message = message;
    cell.showAvatar = [self showsAvatarAtIndexPath:indexPath];
    cell.bubbleBackgroundColor = [self.messageCellDelegate bubbleColorForMessage:message];
    return cell;
}

@end
