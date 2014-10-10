//
//  MessageDetailViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/10/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "MessageDetailViewController.h"
#import <HMSegmentedControl.h>
#import "MessageCell.h"
#import "DefaultMessageCellDelegate.h"

@interface MessageDetailViewController()

@property (strong, nonatomic) id<MessageCellDelegate> messageCellDelegate;
@property (strong, nonatomic) UIView *segmentedControlContainerView;
@property (strong, nonatomic) HMSegmentedControl *segmentedControl;

@end

@implementation MessageDetailViewController

- (instancetype)initWithMessage:(Message *)message
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.messageCellDelegate = [[DefaultMessageCellDelegate alloc] init];
        self.message = message;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"READ", @"UNREAD"]];
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.backgroundColor = [UIColor clearColor];
    self.segmentedControl.font = [ThemeManager regularFontOfSize:12.5];
    self.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    CGFloat selectedSegmentBuffer = 22;
    self.segmentedControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, -selectedSegmentBuffer, 0, -2*selectedSegmentBuffer);
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:58/255.0 green:172/255.0 blue:65/255.0 alpha:1.0];
    self.segmentedControl.selectionIndicatorHeight = 3;
    self.segmentedControl.textColor = [UIColor colorWithRed:76/255.0 green:80/255.0 blue:88/255.0 alpha:0.4];
    self.segmentedControl.selectedTextColor = [self.segmentedControl.textColor colorWithAlphaComponent:1.0];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControlContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    self.segmentedControlContainerView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    [self.segmentedControlContainerView addEdge:UIRectEdgeBottom width:0.5 color:[UIColor colorWithRed:234/255.0 green:235/255.0 blue:236/255.0 alpha:1.0]];
    [self.segmentedControlContainerView addSubview:self.segmentedControl];

    
    self.segmentedControl.height = 36;
    self.segmentedControl.width = 280;
    self.segmentedControl.centerX = self.segmentedControlContainerView.width/2.0;
    self.segmentedControl.bottom = self.segmentedControlContainerView.height;
}

- (void)segmentedControlValueChanged:(id)sender
{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    if (section == 0) {
        numRows = 1;
    }
    else {
        
    }
    return numRows;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    return self.segmentedControlContainerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return self.segmentedControlContainerView.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (indexPath.section == 0) {
        Message *message = self.message;
        height = [MessageCell desiredHeightForMessage:message font:[self.messageCellDelegate fontForMessage:message] constrainedToSize:CGSizeMake(self.view.width, CGFLOAT_MAX) textEdgeInsets:[self.messageCellDelegate contentInsetsForMessage:message]];
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self messageCell];
    }
    else {
        return nil;
    }
}

- (MessageCell *)messageCell
{
    MessageCell *messageCell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    messageCell.messageCellDelegate = self.messageCellDelegate;
    messageCell.message = self.message;
    return messageCell;
}


@end
