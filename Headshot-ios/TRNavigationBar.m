//
//  TRNavigationBar.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/31/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "TRNavigationBar.h"

@implementation TRNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews{
    self.backItem.title = @"";
    [super layoutSubviews];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
