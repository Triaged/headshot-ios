//
//  TRKeyboardAccessoryView.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "TRKeyboardAccessoryView.h"
#import <UIBarButtonItem+BlocksKit.h>


@interface TRKeyboardAccessoryView()

@property (strong, nonatomic) UIToolbar *toolBar;

@end

@implementation TRKeyboardAccessoryView

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.toolBar = [[UIToolbar alloc] initWithFrame:self.bounds];
    [self addSubview:self.toolBar];
    return self;
}

- (id)initWithCancel:(void (^)())cancelBlock doneBlock:(void (^)())doneBlock
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain handler:cancelBlock];
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"Done" style:UIBarButtonItemStyleDone handler:doneBlock];
    UIBarButtonItem *spacerItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolBar.items = @[cancelButtonItem, spacerItem, doneButtonItem];
    
    return self;
}




@end
