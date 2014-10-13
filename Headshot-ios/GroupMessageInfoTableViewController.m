//
//  GroupMessageInfoTableViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/30/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "GroupMessageInfoTableViewController.h"
#import "ContactsDataSource.h"
#import "ContactCell.h"
#import "CenterButton.h"

@interface GroupMessageInfoTableViewController ()

@end

@implementation GroupMessageInfoTableViewController

- (id)initWithUsers:(NSArray *)users
{
    self = [self init];
    self.users = users;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self initHeader];
}

- (void)initHeader
{
    self.addMembersButton = [[CenterButton alloc] init];
    self.addMembersButton.titleLabel.font = [ThemeManager regularFontOfSize:9];
    [self.addMembersButton setTitleColor:[[ThemeManager sharedTheme] lightGrayTextColor] forState:UIControlStateNormal];
    UIImage *addMemberImage = [[UIImage imageNamed:@"messages-add-member"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.addMembersButton setImage:addMemberImage forState:UIControlStateNormal];
    [self.addMembersButton setTitle:@"Add Members" forState:UIControlStateNormal];
    self.addMembersButton.tintColor = [[ThemeManager sharedTheme] primaryColor];
    
    self.editNameButton = [[CenterButton alloc] init];
    [self.editNameButton setTitle:@"Edit Name" forState:UIControlStateNormal];
    UIImage *editNameImage = [[UIImage imageNamed:@"messages-edit-name"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.editNameButton setImage:editNameImage forState:UIControlStateNormal];
    self.editNameButton.tintColor = [[ThemeManager sharedTheme] primaryColor];
    
    self.muteButton = [[CenterButton alloc] init];
    UIImage *muteNormalImage = [[UIImage imageNamed:@"messages-mute"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *muteSelectedImage = [[UIImage imageNamed:@"messages-muted"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.muteButton setTitle:@"Mute" forState:UIControlStateNormal];
    [self.muteButton setImage:muteNormalImage forState:UIControlStateNormal];
    [self.muteButton setTitle:@"Unmute" forState:UIControlStateSelected];
    [self.muteButton setImage:muteSelectedImage forState:UIControlStateSelected];
    self.muteButton.tintColor = [[ThemeManager sharedTheme] primaryColor];
}

- (void)setUsers:(NSArray *)users
{
    _users = users;
    [self.tableView reloadData];
}

- (void)showHeaderForMessageThread:(MessageThread *)messageThread
{
    self.tableView.tableHeaderView = [self infoToolBarForMessageThread:messageThread];
}

- (UIView *)infoToolBarForMessageThread:(MessageThread *)messageThread
{
    UIView *toolBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 56)];
    toolBarBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [toolBarBackground addEdge:UIRectEdgeBottom width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
    
    NSArray *buttons;
    if (messageThread.isGroupThread) {
        buttons = @[self.addMembersButton, self.editNameButton, self.muteButton];
    }
    else {
        buttons = @[self.addMembersButton, self.muteButton];
    }
    CGSize buttonSize = CGSizeMake(toolBarBackground.width/buttons.count, toolBarBackground.height);
    [buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CenterButton *button = (CenterButton *)obj;
        button.size = buttonSize;
        button.x = idx*buttonSize.width;
        button.padding = 2;
        [button setTitleColor:[[ThemeManager sharedTheme] lightGrayTextColor] forState:UIControlStateNormal];
        button.titleLabel.font = [ThemeManager regularFontOfSize:9];
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [toolBarBackground addSubview:button];
        if (idx < 2) {
            [button addEdge:UIRectEdgeRight width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
        }
    }];
    
    [toolBarBackground addEdge:UIRectEdgeBottom width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
    return toolBarBackground;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (self.users) {
        numberOfRows = self.users.count;
    }
    return numberOfRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (User *)userForIndexPath:(NSIndexPath *)indexPath
{
    return self.users[indexPath.row];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIndetifier";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.user = [self userForIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(groupMessageInfoTableViewController:didSelectUser:)]) {
        [self.delegate groupMessageInfoTableViewController:self didSelectUser:[self userForIndexPath:indexPath]];
    }
}



@end
