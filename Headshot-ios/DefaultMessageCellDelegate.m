//
//  DefaultMessageCellDelegate.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/10/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "DefaultMessageCellDelegate.h"

@interface DefaultMessageCellDelegate()

@property (strong, nonatomic) UIFont *messageTextFont;
@property (strong, nonatomic) UIColor *incomingTextColor;
@property (strong, nonatomic) UIColor *outgoingTextColor;

@end

@implementation DefaultMessageCellDelegate

- (id)init
{
    self = [super init];
    if (self) {
        self.incomingTextColor = [UIColor blackColor];
        self.outgoingTextColor = [[ThemeManager sharedTheme] primaryColor];
        self.messageTextFont = [ThemeManager lightFontOfSize:17];
    }
    
    return self;
}

- (UIFont *)fontForMessage:(Message *)message
{
    return self.messageTextFont;
}

- (UIColor *)textColorForMessage:(Message *)message
{
    BOOL isUserMessage = [message.author.identifier isEqualToString:[User currentUser].identifier];
    UIColor *color = isUserMessage ? self.outgoingTextColor : self.incomingTextColor;
    return color;
}

- (NSAttributedString *)attributedNameStringForMessage:(Message *)message
{
    BOOL isUserMessage = [message.author.identifier isEqualToString:[User currentUser].identifier];
    if (!isUserMessage) {
        NSMutableAttributedString *attributedNameString = [[NSMutableAttributedString alloc] initWithString:message.author.fullName];
        [attributedNameString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, attributedNameString.string.length)];
        return attributedNameString;
    }
    else {
        return [[NSAttributedString alloc] initWithString:@"Me"];
    }
}

- (UIEdgeInsets)contentInsetsForMessage:(Message *)message
{
    return UIEdgeInsetsMake(7, 17, 7, 30);
}


@end
