//
//  NewMessageThreadViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/3/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "NewMessageThreadViewController.h"
#import <FXBlurView.h>
#import <UINavigationController+SGProgress.h>
#import "UINavigationController+NotificationIndicator.h"
#import "MessageCell.h"
#import "MessageClient.h"
#import "JAKeyboardObserver.h"
#import "JAPlaceholderTextView.h"
#import "GroupMessageInfoTableViewController.h"
#import "DefaultMessageCellDelegate.h"
#import "MessageDetailViewController.h"
#import "CenterButton.h"


@interface NewMessageThreadViewController() <JAKeyboardObserverDelegate, JAPlaceholderTextViewDelegate, GroupMessageInfoTableViewController>

@property (strong, nonatomic) NSMutableOrderedSet *messageQueue;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) id <MessageCellDelegate> messageCellDelegate;
@property (assign, nonatomic) BOOL sendingMessage;
@property (strong, nonatomic) JAKeyboardObserver *keyboardObserver;
@property (strong, nonatomic) GroupMessageInfoTableViewController *groupInfoViewController;
@property (strong, nonatomic) FXBlurView *groupInfoBackgroundView;
@property (assign, nonatomic) BOOL showingGroupInfo;
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

- (instancetype)initWithRecipients:(NSArray *)recipients
{
    NSMutableSet *recipientSet = [NSMutableSet setWithArray:recipients];
    [recipientSet addObject:[User currentUser]];
    MessageThread *thread = [MessageThread findThreadWithRecipients:recipientSet];
    if (!thread) {
        [[MessageClient sharedClient] postMessageThreadWithRecipients:recipientSet.allObjects completion:^(MessageThread *messageThread, NSError *error) {
            if (error) {
                [[[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            else {
                self.messageThread = messageThread;
            }
        }];
    }
    self = [self initWithMessageThread:thread];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar-more"] style:UIBarButtonItemStyleDone target:self action:@selector(infoButtonTouched:)];
    self.navigationItem.rightBarButtonItem = infoButton;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [[ThemeManager sharedTheme] tableViewSeparatorColor];
    
    self.messageCellDelegate = [[DefaultMessageCellDelegate alloc] init];
    
    self.textInputbar.backgroundColor = [UIColor colorWithWhite:250/255.0 alpha:1.0];
    self.textView.placeholder = @"Type a message";
    self.textView.font = [ThemeManager lightFontOfSize:15];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.layer.borderWidth = 0;
    self.textView.layer.cornerRadius = 0;
    
    self.textInputbar.rightButton.titleLabel.font = [ThemeManager regularFontOfSize:17];
    [self.textInputbar.rightButton setTitleColor:[[ThemeManager sharedTheme] primaryColor] forState:UIControlStateNormal];
    
    [self.textInputbar.leftButton setImage:[UIImage imageNamed:@"message-icn-add"] forState:UIControlStateNormal];
    self.textInputbar.leftButton.tintColor = [UIColor lightGrayColor];

    self.keyboardObserver = [[JAKeyboardObserver alloc] initWithDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewMessageNotification:) name:kReceivedNewMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessageSentNotification:) name:kMessageSentNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessageFailedNotification:) name:kMessageFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewReadReceiptsNotification:) name:kReceivedNewReadReceiptsNotification object:nil];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)setMessageThread:(MessageThread *)messageThread
{
    [self view];
    _messageThread = messageThread;
    if (messageThread.name) {
        self.navigationItem.title = messageThread.name;
    }
    else {
        self.navigationItem.title = messageThread.defaultTitle;
    }
    [self reloadData];
    [self scrollToBottomAnimated:NO];
}

- (void)receivedNewMessageNotification:(NSNotification *)notification
{
    NSArray *messageIDs = notification.userInfo[@"messages"];
    BOOL reload = NO;
    BOOL showIndicator = NO;
    for (NSManagedObjectID *messageID in messageIDs) {
        Message *message = (Message *)[[NSManagedObjectContext MR_defaultContext] objectWithID:messageID];
        if ([message.messageThread.identifier isEqualToString:self.messageThread.identifier]) {
            reload = YES;
        }
        else {
            showIndicator = YES;
        }
    }
    if (reload) {
        [self reloadData];
        [self.messageThread markAsRead];
        [self scrollToBottomAnimated:YES];
    }
    if (showIndicator) {
        [self.navigationController showNotificationIndicator];
    }
}

- (void)receivedMessageFailedNotification:(NSNotification *)notification
{
    [self reloadData];
    [self cancelProgressBar];
}

- (void)receivedMessageSentNotification:(NSNotification *)notification
{
    NSManagedObjectID *objectID = notification.userInfo[@"message"];
    Message *message = (Message *)[[NSManagedObjectContext MR_contextForCurrentThread] existingObjectWithID:objectID error:nil];
    if (message) {
        [self.messageQueue removeObject:message.uniqueID];
        [self updateProgressBar];
    }
    [self reloadData];
}

- (void)receivedNewReadReceiptsNotification:(NSNotification *)notification
{
    [self reloadData];
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
    return [MessageCell desiredHeightForMessage:message font:[self.messageCellDelegate fontForMessage:message] constrainedToSize:CGSizeMake(self.view.width, CGFLOAT_MAX) textEdgeInsets:[self.messageCellDelegate contentInsetsForMessage:message]];
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
        cell.messageCellDelegate = self.messageCellDelegate;
    }
    cell.message = [self messageForIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self messageForIndexPath:indexPath];
    MessageDetailViewController *messageDetailViewController = [[MessageDetailViewController alloc] initWithMessage:message];
    [self.navigationController pushViewController:messageDetailViewController animated:YES];
}

#pragma mark - Keyboard
- (void)keyboardObserver:(JAKeyboardObserver *)observer receivedWillShowNotificationWithInfo:(JAKeyboardInfo *)info
{
    [self scrollToBottomAnimated:YES];
}


#pragma mark - Group Info
- (void)infoButtonTouched:(id)sender
{
    if (!self.messageThread) {
        return;
    }
    if (self.showingGroupInfo) {
        [self dismissGroupInfo];
    }
    else {
        [self showGroupInfo];
    }
}

- (void)showGroupInfo
{
    self.showingGroupInfo = YES;
    self.groupInfoViewController.users = [self.messageThread.recipientsExcludeUser filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"archived == NO"]].allObjects;;
    if (!self.groupInfoBackgroundView) {
        CGRect frame = CGRectZero;
        if (self.navigationController.navigationBar.isTranslucent) {
            frame.origin.y = self.navigationController.navigationBar.bottom;
            frame.size = CGSizeMake(self.view.width, self.view.height - frame.origin.y);
        }
        else {
            frame = self.view.bounds;
        }
        self.groupInfoBackgroundView = [[FXBlurView alloc] initWithFrame:frame];
        UIView *overlayView = [[UIView alloc] initWithFrame:self.groupInfoBackgroundView.bounds];
        overlayView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        [self.groupInfoBackgroundView addSubview:overlayView];
        self.groupInfoBackgroundView.blurEnabled = YES;
        self.groupInfoBackgroundView.blurRadius = 10;
        self.groupInfoBackgroundView.tintColor = nil;
        self.groupInfoBackgroundView.dynamic = NO;
        self.groupInfoViewController.view.frame = self.groupInfoBackgroundView.bounds;
    }
    [self.groupInfoViewController showHeaderForMessageThread:self.messageThread];
    self.groupInfoViewController.view.backgroundColor = [UIColor clearColor];
    [self addChildViewController:self.groupInfoViewController];
    [self.groupInfoBackgroundView addSubview:self.groupInfoViewController.view];
    [self.view addSubview:self.groupInfoBackgroundView];
    self.groupInfoBackgroundView.alpha = 0;
    self.groupInfoViewController.view.transform = CGAffineTransformMakeTranslation(0, -self.groupInfoViewController.view.height);
    [UIView animateWithDuration:0.3 animations:^{
        self.groupInfoBackgroundView.alpha = 1;
        self.groupInfoViewController.view.transform = CGAffineTransformIdentity;
    }];
}

- (void)dismissGroupInfo
{
    self.showingGroupInfo = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.groupInfoViewController.view.transform = CGAffineTransformMakeTranslation(0, -self.groupInfoViewController.view.height);
        self.groupInfoBackgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.groupInfoBackgroundView removeFromSuperview];
        [self.groupInfoViewController removeFromParentViewController];
    }];
}

- (GroupMessageInfoTableViewController *)groupInfoViewController
{
    if (!_groupInfoViewController) {
        _groupInfoViewController = [[GroupMessageInfoTableViewController alloc] init];
        _groupInfoViewController.delegate = self;
        _groupInfoViewController.tableView.bounces = NO;
        [self updateMuteButton];
    }
    return _groupInfoViewController;
}

- (void)updateMuteButton
{
    UIButton *muteButton = self.groupInfoViewController.muteButton;
    self.groupInfoViewController.muteButton.selected = self.messageThread.muted.boolValue;
}


@end
