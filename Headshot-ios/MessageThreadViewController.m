//
//  MessageViewController.m
//  Headshot-ios
//
//  Created by Charlie White on 5/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "MessageThreadViewController.h"
#import "User.h"
#import "SinchClient.h"
#import "ContactViewController.h"

@interface MessageThreadViewController ()

@property (strong, nonatomic) NSDictionary *avatarImageURLs;
@property (assign, nonatomic) CGSize avatarImageSize;

@end

static NSString * const kJSQDemoAvatarNameCook = @"Tim Cook";
static NSString * const kJSQDemoAvatarNameJobs = @"Jobs";
static NSString * const kJSQDemoAvatarNameWoz = @"Steve Wozniak";

@implementation MessageThreadViewController

@synthesize currentUser;

- (id)initWithMessageThread:(MessageThread *)messageThread
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.messageThread = messageThread;
    }
    return self;
}

-(void)createOrFindThreadForRecipient:(User *)recipient {
    
    MessageThread *thread = [MessageThread MR_findFirstByAttribute:@"recipient" withValue:recipient];
    if (thread == nil) {
        
        thread = [MessageThread MR_createEntity];
        thread.lastMessageTimeStamp = [NSDate date];
        thread.recipient = recipient;
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    
    self.messageThread = thread;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.messageThread.recipient.name;
    
    UIButton *info = [UIButton buttonWithType:UIButtonTypeInfoLight];
    info.tintColor = [[ThemeManager sharedTheme] buttonTintColor];
    [info addTarget:self action:@selector(showContact) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:info];
    self.navigationItem.rightBarButtonItem = item;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchMessages)
                                                 name:[NSString stringWithFormat:@"%@", [self.messageThread objectID] ]
                                               object:nil];

    
    
    currentUser = [AppDelegate sharedDelegate].store.currentAccount.currentUser;
    
    self.sender =  currentUser.name;

    
    [self loadMessages];
    
    self.outgoingBubbleImageView = [JSQMessagesBubbleImageFactory
                                     outgoingMessageBubbleImageViewWithColor:
                                    [[ThemeManager sharedTheme] outgoingMessageBubbleColor]];
    
    self.incomingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    incomingMessageBubbleImageViewWithColor:
                                    [[ThemeManager sharedTheme] incomingMessageBubbleColor]];
    
    self.avatarImageSize = CGSizeMake(40, 40);
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = self.avatarImageSize;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = self.avatarImageSize;

}

-(void)viewWillAppear:(BOOL)animated {
    [[AppDelegate sharedDelegate].tabBarController setTabBarHidden:YES animated:YES];
    self.navigationController.navigationBar.shadowImage = nil;
}

-(void)viewWillDisappear:(BOOL)animated {
    [[AppDelegate sharedDelegate].tabBarController setTabBarHidden:NO animated:YES];
}


-(void)showContact {
    ContactViewController *contactVC = [[ContactViewController alloc] initWitUser:self.messageThread.recipient];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:contactVC animated:YES];
}

- (void)loadMessages
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageThread == %@", self.messageThread];
    self.messages = [NSMutableArray arrayWithArray:[Message MR_findAllWithPredicate:predicate]];

    self.avatarImageURLs = @{self.sender : self.currentUser.avatarFaceUrl,
                             self.messageThread.recipient.name : self.messageThread.recipient.avatarFaceUrl};
    
}

- (void)fetchMessages {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageThread == %@", self.messageThread];
    self.messages = [NSMutableArray arrayWithArray:[Message MR_findAllWithPredicate:predicate]];
    [self finishSendingMessage];
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
    [self createMessageWithText:text andAuthor:currentUser];
    
    
    SINOutgoingMessage *message = [SINOutgoingMessage messageWithRecipient:self.messageThread.recipient.identifier text:text];
    [[SinchClient sharedClient].client.messageClient sendMessage:message];

    
    [self fetchMessages];
    [self finishSendingMessage];
    
}

- (void)createMessageWithText:(NSString *)text andAuthor:(User *)user {
    Message *newMesage = [Message MR_createEntity];
    newMesage.timestamp = [NSDate date];
    newMesage.author = user;
    newMesage.messageThread = self.messageThread;
    newMesage.messageText = text;
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    NSLog(@"Camera pressed!");
    /**
     *  Accessory button has no default functionality, yet.
     */
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    
    if ([message.sender isEqualToString:self.sender]) {
        return [[UIImageView alloc] initWithImage:self.outgoingBubbleImageView.image
                                 highlightedImage:self.outgoingBubbleImageView.highlightedImage];
    }
    
    return [[UIImageView alloc] initWithImage:self.incomingBubbleImageView.image
                             highlightedImage:self.incomingBubbleImageView.highlightedImage];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.avatarImageSize.width, self.avatarImageSize.height)];
    NSURL *imageURL = [NSURL URLWithString:self.avatarImageURLs[message.sender]];
    [imageView setImageWithURL:imageURL];
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
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
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
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if ([msg.sender isEqualToString:self.sender]) {
        cell.textView.textColor = [UIColor whiteColor];
    }
    else {
        
        cell.textView.textColor = [UIColor blackColor];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    return cell;
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



@end
