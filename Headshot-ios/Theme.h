//
//  Theme.h
//  Mutuality
//
//  Created by Jeff Ames on 5/20/13.
//  Copyright (c) 2013 Jeffrey Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Theme <NSObject>

- (NSString *)regularFontName;
- (NSString *)lightFontName;
- (NSString *)italicFontName;
- (NSString *)boldFontName;
- (UIColor *)primaryColor;
- (UIColor *)blueColor;
- (UIColor *)orangeColor;
- (UIColor *)greenColor;
- (UIColor *)darkGrayTextColor;
- (UIColor *)lightGrayTextColor;
- (UIColor *)disabledGrayTextColor;
- (UIColor *)buttonTintColor;
- (UIColor *)primaryColor;
- (UIColor *)tableViewSeparatorColor;
- (UIColor *)incomingMessageBubbleColor;
- (UIColor *)outgoingMessageBubbleColor;
- (UIImage *)backButtonImage;
- (UIImage *)unreadMessageBackButtonImage;
- (void)customizeAppearance;
@end

@interface ThemeManager : NSObject

+ (id <Theme>)sharedTheme;
+ (UIFont *)regularFontOfSize:(CGFloat)size;
+ (UIFont *)lightFontOfSize:(CGFloat)size;
+ (UIFont *)boldFontOfSize:(CGFloat)size;
+ (UIFont *)italicFontOfSize:(CGFloat)size;
+ (UIFont *)titleFontOfSize:(CGFloat)size;

@end
