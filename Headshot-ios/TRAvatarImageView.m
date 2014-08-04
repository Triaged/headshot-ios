//
//  TRAvatarImageView.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/29/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "TRAvatarImageView.h"
#import "TRInitialView.h"

@interface TRAvatarImageView()

@property (strong, nonatomic) TRInitialView *initialView;

@end

@implementation TRAvatarImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    return self;
}

- (TRInitialView *)initialView
{
    if (!_initialView) {
        _initialView = [[TRInitialView alloc] initWithFrame:self.bounds];
        _initialView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _initialView;
}

- (void)setUser:(User *)user
{
    _user = user;
    if (user.avatarFace2xUrl) {
        [self.initialView removeFromSuperview];
        NSURL *url = [NSURL URLWithString:user.avatarFace2xUrl];
        [self setImageWithURL:url placeholderImage:nil];
    }
    else {
        [self addSubview:self.initialView];
        self.initialView.initialsLabel.text = self.user.nameInitials;
        self.image = nil;
    }
}

@end
