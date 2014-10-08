//
//  NewMessageThreadViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/3/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "NewMessageThreadViewController.h"
#import "GroupedMessageCell.h"

@interface NewMessageThreadViewController()

@property (strong, nonatomic) NSArray *sortedMessages;
@property (assign, nonatomic) CGFloat messageSpacing;
@property (strong, nonatomic) UIFont *messageTextFont;
@property (strong, nonatomic) UIColor *incomingBubbleColor;
@property (strong, nonatomic) UIColor *outgoingBubbleColor;
@property (strong, nonatomic) UIColor *incomingTextColor;
@property (strong, nonatomic) UIColor *outgoingTextColor;
@property (assign, nonatomic) CGFloat maxCellWidth;

@end

@implementation NewMessageThreadViewController

- (instancetype)initWithMessageThread:(MessageThread *)messageThread
{
    self = [super initWithStyle:UITableViewStylePlain];
    self.messageThread = messageThread;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.messageSpacing = 10;
    
    self.incomingBubbleColor = [UIColor colorWithRed:234/255.0 green:235/255.0 blue:236/255.0 alpha:1.0];
    self.outgoingBubbleColor = [[ThemeManager sharedTheme] primaryColor];
    
    self.incomingTextColor = [UIColor blackColor];
    self.outgoingTextColor = [UIColor whiteColor];
    
    self.maxCellWidth = 0.93*self.view.width;
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)setMessageThread:(MessageThread *)messageThread
{
    [self view];
    _messageThread = messageThread;
    [self reloadData];
}

- (void)reloadData
{
    self.sortedMessages = [self groupedMessagesForMessages:self.messageThread.messages.allObjects];
    [self.tableView reloadData];
}

- (NSArray *)groupedMessagesForMessages:(NSArray *)messages
{
    NSMutableArray *groupedMessages = [[NSMutableArray alloc] init];
    NSMutableArray *group = [[NSMutableArray alloc] init];
    Message *previous = nil;
    for (Message *message in messages) {
        BOOL same = previous && [previous.author.identifier isEqualToString:message.author.identifier];
        if (same || !previous) {
            [group addObject:message];
        }
        else {
            [groupedMessages addObject:[NSArray arrayWithArray:group]];
            group = [[NSMutableArray alloc] init];
            [group addObject:message];
        }
        previous = message;
    }
    if (group.count) {
        [groupedMessages addObject:group];
    }
    return [NSArray arrayWithArray:groupedMessages];
}

#pragma mark - data source
- (NSArray *)groupedMessagesForIndexPath:(NSIndexPath *)indexPath
{
    return self.sortedMessages[indexPath.section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sortedMessages.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *groupedMessages = [self groupedMessagesForIndexPath:indexPath];
    return [GroupedMessageCell desiredHeightForMessages:groupedMessages constrainedToSize:CGSizeMake(self.maxCellWidth, CGFLOAT_MAX) messageTextInsets:UIEdgeInsetsMake(7, 8, 7, 8)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.messageSpacing;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *HeaderFooterIdentifier = @"Identifier";
    UIView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderFooterIdentifier];
    if (!view) {
        view = [[UIView alloc] init];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"CellIdentifier";
    GroupedMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[GroupedMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.messageCellDelegate = self;
    }
    cell.messages = [self groupedMessagesForIndexPath:indexPath];
    return cell;
}

#pragma mark - Message Cell Delegate
- (UIFont *)fontForMessage:(Message *)message
{
    return [ThemeManager regularFontOfSize:16];
}

- (UIColor *)textColorForMessage:(Message *)message
{
    BOOL isUserMessage = [message.author.identifier isEqualToString:[AppDelegate sharedDelegate].store.currentAccount.currentUser.identifier];
    UIColor *color = isUserMessage ? self.outgoingTextColor : self.incomingTextColor;
    return color;
}

- (UIColor *)bubbleColorForMessage:(Message *)message
{
    BOOL isUserMessage = [message.author.identifier isEqualToString:[AppDelegate sharedDelegate].store.currentAccount.currentUser.identifier];
    UIColor *color = isUserMessage ? self.outgoingBubbleColor : self.incomingBubbleColor;
    return color;
}

- (UIEdgeInsets)textInsetsForMessage:(Message *)message
{
    return UIEdgeInsetsMake(7, 8, 7, 8);
}

- (CGFloat)maxCellWidthForMessage:(Message *)message
{
    return self.maxCellWidth;
}

- (MessageCellAlignment)cellAlignmentForMessage:(Message *)message
{
    BOOL isUserMessage = [message.author.identifier isEqualToString:[AppDelegate sharedDelegate].store.currentAccount.currentUser.identifier];
    return isUserMessage ? MessageCellAlignmentRight : MessageCellAlignmentLeft;
}

@end
