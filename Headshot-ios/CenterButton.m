//
//  CenterButton.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 9/17/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "CenterButton.h"

@implementation CenterButton

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Move the image to the top and center it horizontally
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.x = (self.frame.size.width / 2) - (imageFrame.size.width / 2);
    
    // Adjust the label size to fit the text, and move it below the image
    CGRect titleLabelFrame = self.titleLabel.frame;
    CGSize labelSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.titleLabel.font} context:nil].size;
    titleLabelFrame.size.width = labelSize.width;
    titleLabelFrame.size.height = labelSize.height;
    titleLabelFrame.origin.x = (self.frame.size.width / 2) - (labelSize.width / 2);
    CGFloat imageTitleHeight = imageFrame.size.height + titleLabelFrame.size.height + self.padding;
    imageFrame.origin.y = (self.height - imageTitleHeight)/2.0;
    titleLabelFrame.origin.y = imageFrame.size.height + imageFrame.origin.y + self.padding;
    self.imageView.frame = imageFrame;
    self.titleLabel.frame = titleLabelFrame;

}

@end
