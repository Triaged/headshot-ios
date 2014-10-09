//
//  NewMessageThreadViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/3/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "NewMessageThreadViewController.h"
#import "MessageCell.h"
#import "JAKeyboardObserver.h"

@interface NewMessageThreadViewController() <JAKeyboardObserverDelegate>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) UIFont *messageTextFont;
@property (strong, nonatomic) UIColor *incomingBubbleColor;
@property (strong, nonatomic) UIColor *outgoingBubbleColor;
@property (strong, nonatomic) UIColor *incomingTextColor;
@property (strong, nonatomic) UIColor *outgoingTextColor;
@property (assign, nonatomic) CGFloat maxCellWidth;
@property (strong, nonatomic) UIView *textInputContainer;
//@property (strong, nonatomic) 
@property (strong, nonatomic) JAKeyboardObserver *keyboardObserver;

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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [[ThemeManager sharedTheme] tableViewSeparatorColor];
    
    self.incomingBubbleColor = [UIColor colorWithRed:234/255.0 green:235/255.0 blue:236/255.0 alpha:1.0];
    self.outgoingBubbleColor = [[ThemeManager sharedTheme] primaryColor];
    
    self.incomingTextColor = [UIColor blackColor];
    self.outgoingTextColor = [[ThemeManager sharedTheme] primaryColor];
    
    self.maxCellWidth = 0.93*self.view.width;
    
    self.keyboardObserver = [[JAKeyboardObserver alloc] initWithDelegate:self];
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
    self.messages = [NSMutableArray arrayWithArray:[Message MR_findByAttribute:@"messageThread" withValue:self.messageThread andOrderBy:@"timestamp" ascending:YES]];
    [self.tableView reloadData];
}

#pragma mark - data source

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self messageForIndexPath:indexPath];
    return [MessageCell desiredHeightForMessage:message font:[self fontForMessage:message] constrainedToSize:CGSizeMake(self.view.width, CGFLOAT_MAX) textEdgeInsets:UIEdgeInsetsMake(7, 8, 7, 8)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"CellIdentifier";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.messageCellDelegate = self;
    }
    cell.message = [self messageForIndexPath:indexPath];
    return cell;
}

#pragma mark - Message Cell Delegate
- (UIFont *)fontForMessage:(Message *)message
{
    return [ThemeManager lightFontOfSize:17];
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

- (UIEdgeInsets)contentInsetsForMessage:(Message *)message
{
    return UIEdgeInsetsMake(7, 17, 7, 30);
}

- (CGFloat)maxCellWidthForMessage:(Message *)message
{
    return self.maxCellWidth;
}


#pragma mark - Keyboard
- (void)keyboardObserver:(JAKeyboardObserver *)observer receivedWillChangeFrameNotificationWithInfo:(JAKeyboardInfo *)info
{
    
}

@end
