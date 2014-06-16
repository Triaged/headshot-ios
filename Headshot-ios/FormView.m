//
//  FormView.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "FormView.h"

@interface FormView()

@property (strong, nonatomic) UILabel *fieldNameLabel;

@end

@implementation FormView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    self.fieldNameLabel = [[UILabel alloc] init];
    [self addSubview:self.fieldNameLabel];
    self.textField = [[UITextField alloc] init];
    [self addSubview:self.textField];
    [self setDefaultAppearance];
    
    return self;
}

- (void)setDefaultAppearance
{
    self.fieldNameLabel.textColor = [[ThemeManager sharedTheme] darkGrayTextColor];
    self.fieldNameLabel.font = [ThemeManager regularFontOfSize:17];
    
    self.textField.textColor = [[ThemeManager sharedTheme] greenColor];
    self.textField.font = [ThemeManager regularFontOfSize:18];
    self.textField.tintColor = [[ThemeManager sharedTheme] orangeColor];
}

- (void)layout
{
    self.fieldNameLabel.x = 17;
    self.fieldNameLabel.size = CGSizeMake(self.width, self.height);
    self.fieldNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    
    CGSize size = [self.fieldNameLabel.text sizeWithAttributes:@{NSFontAttributeName : self.fieldNameLabel.font}];
    self.textField.x = self.fieldNameLabel.x + size.width + 20;
    self.textField.size = CGSizeMake(self.width, self.height);
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
}

- (void)setFieldName:(NSString *)fieldName
{
    _fieldName = fieldName;
    self.fieldNameLabel.text = fieldName;
    [self layout];
}


@end
