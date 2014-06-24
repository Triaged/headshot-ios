//
//  UIImage+SolidColor.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "UIImage+SolidColor.h"

@implementation UIImage (SolidColor)

+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
