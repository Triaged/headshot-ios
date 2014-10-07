//
//  BAFormView.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/7/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "BAFormView.h"

@implementation BAFormView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title placeholder:(NSString *)placeholder
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureWithTitle:title placeholder:placeholder];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title placeholder:(NSString *)placeholder
{
    self.titleLabel = [[UILabel alloc] init];
    [self addSubview:self.titleLabel];
    self.titleLabel.font = [ThemeManager lightFontOfSize:12];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    self.titleLabel.x = 17;
    self.titleLabel.y = 9;
    
    self.textField = [[UITextField alloc] init];
    self.textField = self.textField;
    [self addSubview:self.textField];
    self.textField.placeholder = placeholder;
    self.textField.font = [ThemeManager lightFontOfSize:18];
    self.textField.textColor = [[ThemeManager sharedTheme] primaryColor];
    [self.textField sizeToFit];
    self.textField.x = self.titleLabel.x;
    self.textField.width = self.width - self.textField.x;
    self.textField.bottom = self.height - 14;
}

@end
