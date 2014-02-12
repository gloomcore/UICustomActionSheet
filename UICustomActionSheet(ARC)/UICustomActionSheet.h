//
//  UICustomActionSheet.h
//  UICustomActionSheetSample
//
//  Copyright (C) 2011 by gloomcore.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <UIKit/UIKit.h>

@interface UICustomActionSheet : UIActionSheet{
    NSMutableArray *_buttonAttributes;
    BOOL _isFlatDesign;
    BOOL _isIpad;
}

-(void)setFont:(UIFont *)font forButtonAtIndex:(NSInteger)index;
-(UIFont *)fontForButtonAtIndex:(NSInteger)index;

-(void)setColor:(UIColor *)color forButtonAtIndex:(NSInteger)index;
-(UIColor *)colorForButtonAtIndex:(NSInteger)index;
-(void)setPressedColor:(UIColor *)color forButtonAtIndex:(NSInteger)index;
-(UIColor *)pressedColorForButtonAtIndex:(NSInteger)index;

-(void)setTextColor:(UIColor *)color forButtonAtIndex:(NSInteger)index;
-(UIColor *)textColorForButtonAtIndex:(NSInteger)index;
-(void)setPressedTextColor:(UIColor *)color forButtonAtIndex:(NSInteger)index;
-(UIColor *)pressedTextColorForButtonAtIndex:(NSInteger)index;

//Image methods
-(void)setImage:(UIImage *)image forButtonAtIndex:(NSInteger)index;
-(UIImage *)imageForButtonAtIndex:(NSInteger)index;

@end
