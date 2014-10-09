//
//  TagSetTableViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/8/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "TagSetTableViewController.h"
#import "TagSetItem.h"

@interface TagSetTableViewController ()

@property (strong, nonatomic) NSArray *tagSetItems;

@end

@implementation TagSetTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)setTagSet:(TagSet *)tagSet
{
    _tagSet = tagSet;
    [self reloadData];
}

- (void)setPreviousTagSetItems:(NSArray *)previousTagSetItems
{
    _previousTagSetItems = previousTagSetItems;
    [self reloadData];
}

- (void)reloadData
{
    NSMutableArray *tagSetItems = [[NSMutableArray alloc] initWithArray:self.tagSet.tagSetItems.allObjects];
        for (TagSetItem *tagSetItem in self.tagSet.tagSetItems) {
            NSMutableArray *allTags = [[NSMutableArray alloc] init];
            if (self.previousTagSetItems) {
                [allTags addObjectsFromArray:self.previousTagSetItems];
            }
            [allTags addObject:tagSetItem];
            NSInteger count = [User findAllIntersectingfItems:allTags excludeCurrent:YES].count;
            if (!count) {
                [tagSetItems removeObject:tagSetItem];
            }
        }
    self.tagSetItems = [NSArray arrayWithArray:tagSetItems];
    [self.tableView reloadData];
}


#pragma mark - Table view data source
- (TagSetItem *)tagSetItemForIndexPath:(NSIndexPath *)indexPath
{
    return self.tagSetItems[indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tagSetItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    TagSetItem *tagSetItem = [self tagSetItemForIndexPath:indexPath];
    cell.textLabel.text = tagSetItem.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TagSetItem *item = [self tagSetItemForIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(tagSetTableViewController:didSelectTagSetItem:)]) {
        [self.delegate tagSetTableViewController:self didSelectTagSetItem:item];
    }
}

@end
