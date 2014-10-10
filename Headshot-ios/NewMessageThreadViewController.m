//
//  NewMessageThreadViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/3/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "NewMessageThreadViewController.h"
#import <UINavigationController+SGProgress.h>
#import "MessageCell.h"
#import "MessageClient.h"
#import "JAKeyboardObserver.h"
#import "JAPlaceholderTextView.h"

@interface NewMessageThreadViewController() <JAKeyboardObserverDelegate, JAPlaceholderTextViewDelegate>

@property (strong, nonatomic) NSMutableOrderedSet *messageQueue;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) UIFont *messageTextFont;
@property (strong, nonatomic) UIColor *incomingBubbleColor;
@property (strong, nonatomic) UIColor *outgoingBubbleColor;
@property (strong, nonatomic) UIColor *incomingTextColor;
@property (strong, nonatomic) UIColor *outgoingTextColor;
@property (assign, nonatomic) BOOL sendingMessage;
@property (assign, nonatomic) CGFloat maxCellWidth;
@property (strong, nonatomic) JAKeyboardObserver *keyboardObserver;
@property (strong, nonatomic) NSTimer *progressTimer;
@property (assign, nonatomic) NSTimeInterval progressDuration;
@property (assign, nonatomic) CGFloat progressPercentage;
@property (assign, nonatomic) CGFloat progressUpdateInterval;

@end

@implementation NewMessageThreadViewController

- (instancetype)initWithMessageThread:(MessageThread *)messageThread
{
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    self.messageThread = messageThread;
    self.inverted = NO;
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
    
    self.textInputbar.backgroundColor = [UIColor colorWithWhite:250/255.0 alpha:1.0];
    self.textView.placeholder = @"Type a message";
    self.textView.font = [ThemeManager lightFontOfSize:15];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.layer.borderWidth = 0;
    self.textView.layer.cornerRadius = 0;
    
    self.textInputbar.rightButton.titleLabel.font = [ThemeManager regularFontOfSize:17];
    [self.textInputbar.rightButton setTitleColor:[[ThemeManager sharedTheme] primaryColor] forState:UIControlStateNormal];

    self.keyboardObserver = [[JAKeyboardObserver alloc] initWithDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewMessageNotification:) name:kReceivedNewMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessageSentNotification:) name:kMessageSentNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessageFailedNotification:) name:kMessageFailedNotification object:nil];
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
    [self scrollToBottomAnimated:NO];
}

- (void)didPressRightButton:(id)sender
{
    Message *message = [self createMessageWithText:self.textView.text andAuthor:[User currentUser]];
    [self sendMessage:message];
    [self clearTextField];
}

- (void)sendMessage:(Message *)message
{
    [self.messageQueue addObject:message];
    [self startProgressBar];
    self.sendingMessage = YES;
    NSLog(@"sending message %@", message);
    [[MessageClient sharedClient] sendMessage:message withCompletion:^(Message *message, NSError *error) {
        self.sendingMessage = NO;
        NSLog(@"completing message %@", message);
        [self.messageQueue removeObject:message];
        [self updateProgressBar];
        [self reloadData];
    }];
    [self reloadData];
    [self scrollToBottomAnimated:YES];
    [[AnalyticsManager sharedManager] messageSent];
}

- (void)resendMessage:(Message *)message
{
    if (!self.sendingMessage) {
        [self sendMessage:message];
    }
}

- (Message *)createMessageWithText:(NSString *)text andAuthor:(User *)user {
    Message *newMessage = [Message MR_createEntity];
    newMessage.timestamp = [NSDate date];
    newMessage.author = user;
    newMessage.messageThread = self.messageThread;
    newMessage.messageText = text;
    return newMessage;
}

- (void)clearTextField
{
    self.textView.text = nil;
}

#pragma mark - Progress Bar
- (void)updateProgressBar
{
    if (!self.messageQueue.count) {
        [self finishProgressBar];
    }
    else {
        self.progressPercentage += 100*self.progressUpdateInterval/(self.progressDuration);
        self.progressPercentage = MIN(75, self.progressPercentage);
        [self setProgessPercentage:self.progressPercentage failed:NO];
    }
}

- (void)setProgessPercentage:(CGFloat)progressPercentage failed:(BOOL)failed
{
    UIColor *tintColor = failed ? [UIColor redColor] : [[ThemeManager sharedTheme] primaryColor];
    [self.navigationController setSGProgressPercentage:progressPercentage andTintColor:tintColor];
}

- (void)startProgressBar
{
    self.progressDuration = 1.5;
    self.progressUpdateInterval = 0.1;
    self.progressPercentage = 0;
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:self.progressUpdateInterval target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
    [self updateProgressBar];
}

- (void)finishProgressBar
{
    [self setProgessPercentage:100 failed:NO];
    [self.progressTimer invalidate];
}

- (void)cancelProgressBar
{
    [self setProgessPercentage:0 failed:YES];
    [self.progressTimer invalidate];
}

- (void)reloadData
{
    self.messages = [NSMutableArray arrayWithArray:[Message MR_findByAttribute:@"messageThread" withValue:self.messageThread andOrderBy:@"timestamp" ascending:YES]];
    [self.tableView reloadData];
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    if ([self.tableView numberOfSections] == 0) {
        return;
    }
    
    NSInteger items = [self.tableView numberOfRowsInSection:0];
    
    if (items > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:items - 1 inSection:0]
                                    atScrollPosition:UITableViewScrollPositionTop
                                            animated:animated];
    }
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
    BOOL isUserMessage = [message.author.identifier isEqualToString:[User currentUser].identifier];
    UIColor *color = isUserMessage ? self.outgoingTextColor : self.incomingTextColor;
    return color;
}

- (UIColor *)bubbleColorForMessage:(Message *)message
{
    BOOL isUserMessage = [message.author.identifier isEqualToString:[User currentUser].identifier];
    UIColor *color = isUserMessage ? self.outgoingBubbleColor : self.incomingBubbleColor;
    return color;
}

- (NSAttributedString *)attributedNameStringForMessage:(Message *)message
{
    BOOL isUserMessage = [message.author.identifier isEqualToString:[User currentUser].identifier];
    if (!isUserMessage) {
        UIColor *lightGrayColor = [UIColor colorWithRed:202/255.0 green:204/255.0 blue:209/255.0 alpha:1.0];
        NSMutableAttributedString *attributedNameString = [[NSMutableAttributedString alloc] initWithString:message.author.fullName];
        [attributedNameString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:[attributedNameString.string rangeOfString:message.author.firstName]];
        [attributedNameString addAttribute:NSForegroundColorAttributeName value:lightGrayColor range:[attributedNameString.string rangeOfString:message.author.lastName]];
        return attributedNameString;
    }
    else {
        return [[NSAttributedString alloc] initWithString:@"Me"];
    }
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
- (void)keyboardObserver:(JAKeyboardObserver *)observer receivedWillShowNotificationWithInfo:(JAKeyboardInfo *)info
{
    [self scrollToBottomAnimated:YES];
}

@end
