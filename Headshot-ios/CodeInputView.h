//
//  CodeInputView.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/1/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CodeInputView;
@protocol CodeInputViewDelegate <NSObject>

- (void)codeInputView:(CodeInputView *)codeInputView didFinishEnteringCode:(NSString *)code;

@end

@interface CodeInputView : UIView

@property (weak, nonatomic) id<CodeInputViewDelegate> delegate;
@property (strong, nonatomic) UIFont *font;
@property (readonly) NSString *code;
@property (readonly) NSArray *textFields;
@property (readonly) CGSize cellSize;
@property (readonly) NSInteger codeLength;

- (instancetype)initWithCellSize:(CGSize)cellSize horizontalGap:(CGFloat)horizontalGap codeLength:(NSInteger)codeLength;
- (void)becomeFirstResponder;
- (void)clear;

@end
