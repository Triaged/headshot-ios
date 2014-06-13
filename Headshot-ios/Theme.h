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
- (UIColor *)darkGrayTextColor;
- (UIColor *)lightGrayTextColor;
- (UIColor *)buttonTintColor;
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
