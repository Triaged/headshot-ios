//
//  MessageViewController.m
//  Headshot-ios
//
//  Created by Charlie White on 5/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "MessageThreadViewController.h"
#import <UINavigationController+SGProgress.h>
#import <FXBlurView.h>
#import "User.h"
#import "ContactViewController.h"
#import "GroupMessageInfoTableViewController.h"
#import "NotificationManager.h"
#import "HeadshotAPIClient.h"
#import "MessageClient.h"
#import "TRAvatarImageView.h"

@interface MessageThreadViewController () <GroupMessageInfoTableViewController>

@property (assign, nonatomic) CGSize avatarImageSize;
@property (strong, nonatomic) NSMutableOrderedSet *messageQueue;
@property (strong, nonatomic) NSDate *lastSentMessageDate;
@property (strong, nonatomic) NSTimer *progressTimer;
@property (assign, nonatomic) NSTimeInterval progressDuration;
@property (assign, nonatomic) CGFloat progressPercentage;
@property (assign, nonatomic) CGFloat progressUpdateInterval;
@property (strong, nonatomic) GroupMessageInfoTableViewController *groupInfoViewController;
@property (strong, nonatomic) FXBlurView *groupInfoBackgroundView;
@property (assign, nonatomic) BOOL showingGroupInfo;

@end

@implementation MessageThreadViewController

@synthesize currentUser;

- (id)initWithMessageThread:(MessageThread *)messageThread
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.messageThread = messageThread;
        self.messageQueue = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}

- (id)initWithThreadID:(NSString *)threadID
{
    MessageThread *thread = [MessageThread MR_findFirstByAttribute:NSStringFromSelector(@selector(identifier)) withValue:threadID];
    [[MessageClient sharedClient] refreshMessagesWithCompletion:^(NSArray *messages, NSArray *createdMessages, NSArray *createdMessageThreads, NSError *error) {
        MessageThread *fetchedThread = [MessageThread MR_findFirstByAttribute:NSStringFromSelector(@selector(identifier)) withValue:threadID];
        if (!fetchedThread) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        self.messageThread = fetchedThread;
    }];
    self = [self initWithMessageThread:thread];
    return self;
}

- (id)initWithRecipient:(User *)recipient
{
    self = [self initWithRecipients:@[recipient]];
    return self;
}

- (id)initWithRecipients:(NSArray *)recipients
{
    NSMutableSet *recipientSet = [NSMutableSet setWithArray:recipients];
    [recipientSet addObject:[AppDelegate sharedDelegate].store.currentAccount.currentUser];
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
    // Do any additional setup after loading the view.
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    NSString *sendTitle = NSLocalizedString(@"Send", @"Text for the send button on the messages view toolbar");
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [sendButton setTitle:sendTitle forState:UIControlStateNormal];
    [sendButton setTitleColor:[[ThemeManager sharedTheme] greenColor]  forState:UIControlStateNormal];
    [sendButton setTitleColor:[[[ThemeManager sharedTheme] greenColor] jsq_colorByDarkeningColorWithValue:0.1f] forState:UIControlStateHighlighted];
    [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    sendButton.contentMode = UIViewContentModeCenter;
    sendButton.backgroundColor = [UIColor clearColor];
    sendButton.tintColor = [[ThemeManager sharedTheme] greenColor];
    sendButton.enabled = NO;
    self.inputToolbar.contentView.rightBarButtonItem = sendButton;
    
    UIButton *info = [UIButton buttonWithType:UIButtonTypeInfoLight];
    info.tintColor = [[ThemeManager sharedTheme] buttonTintColor];
    [info addTarget:self action:@selector(infoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:info];
    self.navigationItem.rightBarButtonItem = item;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewMessageNotification:) name:kReceivedNewMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessageSentNotification:) name:kMessageSentNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessageFailedNotification:) name:kMessageFailedNotification object:nil];

    
    currentUser = [AppDelegate sharedDelegate].store.currentAccount.currentUser;
    self.sender =  currentUser.fullName;

    
    [self loadMessages];
    
    self.outgoingBubbleImageView = [JSQMessagesBubbleImageFactory
                                     outgoingMessageBubbleImageViewWithColor:
                                    [[ThemeManager sharedTheme] outgoingMessageBubbleColor]];
    
    self.incomingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    incomingMessageBubbleImageViewWithColor:
                                    [[ThemeManager sharedTheme] incomingMessageBubbleColor]];
    self.failedBubbleImageView = [JSQMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[[ThemeManager sharedTheme] outgoingMessageBubbleColor]];
    
    self.avatarImageSize = CGSizeMake(40, 40);
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = self.avatarImageSize;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = self.avatarImageSize;
}

- (void)setMessageThread:(MessageThread *)messageThread
{
    _messageThread = messageThread;
    self.title = messageThread.defaultTitle;
    [self fetchMessages];
}

- (GroupMessageInfoTableViewController *)groupInfoViewController
{
    if (!_groupInfoViewController) {
        _groupInfoViewController = [[GroupMessageInfoTableViewController alloc] init];
        _groupInfoViewController.view.frame = self.view.bounds;
        _groupInfoViewController.delegate = self;
    }
    return _groupInfoViewController;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)receivedNewMessageNotification:(NSNotification *)notification
{
//    MessageThread *thread = notification.userInfo[@"thread"];
//    if ([thread.objectID isEqual:self.messageThread.objectID]) {
        [self fetchMessages];
//    }
}

- (void)receivedMessageFailedNotification:(NSNotification *)notification
{
    [self fetchMessages];
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
    [self fetchMessages];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.shadowImage = nil;
    [NotificationManager sharedManager].visibleMessageThreadViewController = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [NotificationManager sharedManager].visibleMessageThreadViewController = nil;
    [self.navigationController setSGProgressPercentage:0];
}


- (void)updateProgressBar
{
    if (!self.messageQueue.count) {
        [self finishProgressBar];
    }
    else {
        self.progressPercentage += 100*self.progressUpdateInterval/(self.progressDuration);
        self.progressPercentage = MIN(75, self.progressPercentage);
        [self.navigationController setSGProgressPercentage:self.progressPercentage andTintColor:[[ThemeManager sharedTheme] orangeColor]];
    }
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
    [self.navigationController setSGProgressPercentage:100 andTintColor:[[ThemeManager sharedTheme] orangeColor]];
    [self.progressTimer invalidate];
}

- (void)cancelProgressBar
{
    [self.navigationController setSGProgressPercentage:0 andTintColor:[UIColor redColor]];
    [self.progressTimer invalidate];
}

- (void)infoButtonTouched:(id)sender
{
    if (!self.messageThread) {
        return;
    }
    if (self.messageThread.isGroupThread) {
        if (self.showingGroupInfo) {
            [self dismissGroupInfo];
        }
        else {
            [self showGroupInfo];
        }
    }
    else {
        [self showContact:self.messageThread.directMessageRecipient];
    }
}

- (void)showGroupInfo
{
    self.showingGroupInfo = YES;
    self.groupInfoViewController.users = self.messageThread.recipientsExcludeUser.allObjects;
    if (!self.groupInfoBackgroundView) {
        self.groupInfoBackgroundView = [[FXBlurView alloc] initWithFrame:self.view.bounds];
        UIView *overlayView = [[UIView alloc] initWithFrame:self.groupInfoBackgroundView.bounds];
        overlayView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        [self.groupInfoBackgroundView addSubview:overlayView];
        self.groupInfoBackgroundView.blurEnabled = YES;
        self.groupInfoBackgroundView.blurRadius = 10;
        self.groupInfoBackgroundView.tintColor = nil;
        self.groupInfoBackgroundView.dynamic = NO;
    }
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
    }];
}

-(void)showContact:(User *)user
{
    ContactViewController *contactVC = [[ContactViewController alloc] initWitUser:user];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:contactVC animated:YES];
}

- (void)loadMessages
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageThread == %@", self.messageThread];
    self.messages = [NSMutableArray arrayWithArray:[Message MR_findAllWithPredicate:predicate]];
}

- (void)fetchMessages {
    self.messages = [NSMutableArray arrayWithArray:[Message MR_findByAttribute:@"messageThread" withValue:self.messageThread andOrderBy:@"timestamp" ascending:YES]];
    [self.collectionView reloadData];
    if (self.automaticallyHandlesScrolling) {
        [self scrollToBottomAnimated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                    sender:(NSString *)sender
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    Message *message = [self createMessageWithText:text andAuthor:currentUser];
    [self sendMessage:message];
    
    [self fetchMessages];
    [self finishSendingMessage];
}

- (void)sendMessage:(Message *)message
{
    [self startProgressBar];
    [self.messageQueue addObject:message];
    [[MessageClient sharedClient] sendMessage:message withCompletion:^(Message *message, NSError *error) {
        [self.messageQueue removeObject:message];
        [self fetchMessages];
    }];
    [[AnalyticsManager sharedManager] messageSent];
}

- (void)resendMessage:(Message *)message
{
    [self sendMessage:message];
}

- (Message *)createMessageWithText:(NSString *)text andAuthor:(User *)user {
    Message *newMessage = [Message MR_createEntity];
    newMessage.timestamp = [NSDate date];
    newMessage.author = user;
    newMessage.messageThread = self.messageThread;
    newMessage.messageText = text;
    return newMessage;
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self messageForIndexPath:indexPath];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.messages objectAtIndex:indexPath.item];
    
    
    UIImageView *imageView;
    if ([message.sender isEqualToString:self.sender]) {
        if (message.failed.boolValue) {
            imageView = [[UIImageView alloc] initWithImage:self.failedBubbleImageView.image highlightedImage:self.failedBubbleImageView.highlightedImage];
        }
        else {
            imageView = [[UIImageView alloc] initWithImage:self.outgoingBubbleImageView.image
                                          highlightedImage:self.outgoingBubbleImageView.highlightedImage];
        }
    }
    else {
        
        imageView = [[UIImageView alloc] initWithImage:self.incomingBubbleImageView.image
                                      highlightedImage:self.incomingBubbleImageView.highlightedImage];
    }
    return imageView;
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.messages objectAtIndex:indexPath.item];
    TRAvatarImageView *imageView = [[TRAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, self.avatarImageSize.width, self.avatarImageSize.height)];
    if (message.failed.boolValue) {
        imageView.image = [UIImage imageNamed:@"messages-resend"];
    }
    else {
        imageView.user = message.author;
    }
    return imageView;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        Message *message = [self messageForIndexPath:indexPath];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.sender isEqualToString:self.sender]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:message.sender]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.sender];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (Message *)messageForIndexPath:(NSIndexPath *)indexPath
{
    return self.messages[indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    Message *msg = [self messageForIndexPath:indexPath];
    
    if ([msg.sender isEqualToString:self.sender]) {
        cell.textView.textColor = [UIColor whiteColor];
    }
    else {
        
        cell.textView.textColor = [UIColor blackColor];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapon:)];
//    [cell addGestureRecognizer:tap];
    
    return cell;
}

- (void)messagesCollectionViewCellDidTapAvatar:(JSQMessagesCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    Message *message = [self messageForIndexPath:indexPath];
    if (message.failed.boolValue) {
        [self resendMessage:message];
    }
}

#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    //give a little extra room between messages if no label
    return 5.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage sender] isEqualToString:self.sender]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:[currentMessage sender]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

#pragma mark - Group Message Info Delegate
- (void)groupMessageInfoTableViewController:(GroupMessageInfoTableViewController *)groupMessageInfoViewController didSelectUser:(User *)user
{
    [self showContact:user];
}



@end
