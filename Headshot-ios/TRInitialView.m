//
//  TRInitialView.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/27/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "TRInitialView.h"

@implementation TRInitialView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.backgroundColor = [UIColor colorWithWhite:195/255.0 alpha:1.0];
    self.initialsLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.initialsLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.initialsLabel.textAlignment = NSTextAlignmentCenter;
    self.initialsLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.initialsLabel];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius = self.frame.size.width/2.0;
    self.initialsLabel.font = [ThemeManager regularFontOfSize:self.frame.size.width/2];
}

@end
