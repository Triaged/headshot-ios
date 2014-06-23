//
//  EditAvatarImageView.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "EditAvatarImageView.h"

@implementation EditAvatarImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.layer.cornerRadius = self.width/2.0;
    self.layer.borderColor = [[ThemeManager sharedTheme] orangeColor].CGColor;
    self.layer.borderWidth = 1;
    self.clipsToBounds = YES;
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.imageView];
    
    self.opacityView = [[UIView alloc] initWithFrame:self.bounds];
    self.opacityView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [self addSubview:self.opacityView];
    
    self.addPhotoLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.addPhotoLabel.textAlignment = NSTextAlignmentCenter;
    self.addPhotoLabel.font = [ThemeManager regularFontOfSize:14];
    self.addPhotoLabel.textColor = [[ThemeManager sharedTheme] orangeColor];
    self.addPhotoLabel.text = @"ADD PHOTO";
    [self addSubview:self.addPhotoLabel];
    
    return self;
}

@end
