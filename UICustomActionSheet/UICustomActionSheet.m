//
//  UICustomActionSheet.m
//  UICustomActionSheetSample
//
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

#include <stdarg.h>

#import "UICustomActionSheet.h"
#import <QuartzCore/QuartzCore.h>

#define BAR_SIZE 5.0f
#define VIEW_ROUND_RECT 10.0f
#define CAS_IMAGE_VERTICAL_INSET 2.0f
#define CAS_IMAGE_HORIZONTAL_INSET 10.0f

@interface  UICustomActionSheet(Private)
-(id)valueOfAttribute:(NSString *)param forButtonAtIndex:(NSInteger)index;
-(void)setValue:(id)value ofAttribute:(NSString *)param forButtonAtIndex:(NSInteger)index;

-(NSMutableDictionary *)paramsForButtonWithIndex:(NSInteger)index;
@end

@implementation UICustomActionSheet

#pragma mark init methods

-(id)initWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super initWithTitle:title delegate:delegate 
              cancelButtonTitle:nil
         destructiveButtonTitle:nil 
              otherButtonTitles:nil];
    
    if (self)
    {
        _buttonAttributes = [[NSMutableArray alloc] init];
 
        //Add destructive button if needed
        if (destructiveButtonTitle != nil)
        {
            self.destructiveButtonIndex = [self addButtonWithTitle:destructiveButtonTitle];
        }
                
        va_list arglist;
        va_start(arglist, otherButtonTitles);
            
        NSString *buttonTitle = otherButtonTitles;
        while (buttonTitle != nil){
            [self addButtonWithTitle:buttonTitle]; //Add simple button
            buttonTitle = va_arg(arglist, id);
        }
        
        va_end(arglist);                
        
        //Add cancel button if needed
        if (cancelButtonTitle != nil)
        {
            self.cancelButtonIndex = [self addButtonWithTitle:cancelButtonTitle];
        }                
    }
    
    return self;
}

#pragma mark buttonTittle methods

-(NSInteger)addButtonWithTitle:(NSString *)title{
    //Use title button as "", to cancel text drawing by superclass.
    NSInteger index = [super addButtonWithTitle:@""];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (title != NULL)
        [dict setObject:title forKey:@"text"];
    
    [_buttonAttributes insertObject:dict atIndex:index];
    
    return index;
}

-(NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex{
    //Return real text value, cause supermethod will return empty string.
    NSString *text = [[_buttonAttributes objectAtIndex:buttonIndex] objectForKey:@"text"];
    
    return text;
}

#pragma mark Customize button methods

-(void)addColorGradients:(UIColor *)color forLayer:(CALayer *)bgLayer{
    //Using dirty white color of backgroud color
    bgLayer.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f].CGColor;
    
    //If background color is set, build gradient layers for current color
    CGRect firstFrame = bgLayer.bounds, secondFrame = bgLayer.bounds;
    firstFrame.size.height = bgLayer.bounds.size.height / 2.0f;
    secondFrame.size.height = bgLayer.bounds.size.height / 2.0f;
    secondFrame.origin.y = bgLayer.bounds.size.height / 2.0f;
    
    //Upper linear gradient preparing
    CAGradientLayer *gradientLayer1 = [[CAGradientLayer alloc] init];
    [gradientLayer1 setFrame:firstFrame];
    NSArray *colors1 = [NSArray arrayWithObjects:
                        (id)[color colorWithAlphaComponent:0.4f].CGColor,
                        (id)[color colorWithAlphaComponent:0.7f].CGColor,
                        nil];
    [gradientLayer1 setColors:colors1];
    gradientLayer1.startPoint = CGPointMake(0.0f, 0.0f);
    gradientLayer1.endPoint = CGPointMake(0.0f, 1.0f);
    
    //Lower linear gradient prepearing
    CAGradientLayer *gradientLayer2 = [[CAGradientLayer alloc] init];
    [gradientLayer2 setFrame:secondFrame];
    NSArray *colors2 = [NSArray arrayWithObjects:
                        (id)[color colorWithAlphaComponent:1.0f].CGColor,
                        (id)[color colorWithAlphaComponent:0.85f].CGColor,
                        nil];
    [gradientLayer2 setColors:colors2];
    gradientLayer2.startPoint = CGPointMake(0.0f, 0.0f);
    gradientLayer2.endPoint = CGPointMake(0.0f, 1.0f);
    
    [bgLayer insertSublayer:gradientLayer1 atIndex:0];
    [bgLayer insertSublayer:gradientLayer2 atIndex:1];
    
    [gradientLayer1 release];
    [gradientLayer2 release];    
}

-(UILabel *)textLabelForButton:(UIButton *)actionSheetButton atIndex:(NSInteger)buttonIndex{
    UILabel *textLabel = [[UILabel alloc] initWithFrame:actionSheetButton.bounds];
    textLabel.shadowOffset = CGSizeMake(0.0f, -0.1f);
    textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    textLabel.text = [self buttonTitleAtIndex:buttonIndex];
    textLabel.textAlignment = UITextAlignmentCenter;
    textLabel.backgroundColor = [UIColor clearColor];
    
    UIFont *textFont = [self fontForButtonAtIndex:buttonIndex];
    //If font is not customized use standart font of UIActionSheet
    if (textFont == NULL)
        textLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    else
        textLabel.font = textFont;
    
    UIColor *textColor = [self textColorForButtonAtIndex:buttonIndex];
    if (textColor != NULL)
        textLabel.textColor = textColor;
    else if (buttonIndex == self.cancelButtonIndex || buttonIndex == self.destructiveButtonIndex)
        textLabel.textColor = [UIColor whiteColor]; //Standart color of desctructive or cancel button
    else
        textLabel.textColor = [UIColor blackColor]; //Standart text color of simple button 
    
    UIColor *highlightedTextColor = [self pressedTextColorForButtonAtIndex:buttonIndex];
    if (highlightedTextColor == NULL)
        textLabel.highlightedTextColor = [UIColor whiteColor]; //Standart text color of pressed button
    else
        textLabel.highlightedTextColor = highlightedTextColor;
    
    return [textLabel autorelease];
}

-(void)initializeButtonAtIndex:(NSInteger)buttonIndex{
    BOOL titlePresent = (self.title != NULL);
    UIButton *actionSheetButton = (UIButton *)[self.subviews objectAtIndex:buttonIndex + titlePresent];
    [actionSheetButton.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [actionSheetButton.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    BOOL isIpad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    CGRect frame = actionSheetButton.bounds;
    
    if (!isIpad)
        frame = CGRectMake(3.2f, 3.0f, 
                           actionSheetButton.frame.size.width - 6.0f, 
                           actionSheetButton.frame.size.height - 7.0f);
    
    
    UIColor *colors[2] = {[self colorForButtonAtIndex:buttonIndex], 
                          [self pressedColorForButtonAtIndex:buttonIndex]};
    
    for (int index=0; index<2; index++)
    {
        CALayer *bgLayer = [[CALayer alloc] init];
        bgLayer.frame = frame;
        bgLayer.cornerRadius = isIpad ? 4.0f : 8.5f;
        bgLayer.masksToBounds = YES;
        UIColor *color = colors[index];
        
        //If color is not set, than you will button as it should be by default.
        if (color == nil)
        {
            bgLayer.name = @"hidden";
            bgLayer.backgroundColor = [UIColor clearColor].CGColor;
        }
        else
        {
            bgLayer.name = @"shown";
            [self addColorGradients:color forLayer:bgLayer];
        }
        
        bgLayer.opacity = 1.0f - index;
        [actionSheetButton.layer insertSublayer:bgLayer atIndex:index];
        [bgLayer release];
    }
    
    //Add new text color
    UILabel *textLabel = [self textLabelForButton:actionSheetButton atIndex:buttonIndex];
    
    //Prepeare image for button
    UIImage *buttonImage = [self imageForButtonAtIndex:buttonIndex];
    if (buttonImage != NULL)
    {
        CGFloat imageViewHeight = MIN(frame.size.height - CAS_IMAGE_VERTICAL_INSET * 2.0f, 
                                      buttonImage.size.height);
        CGRect imageFrame = CGRectMake(frame.origin.x + CAS_IMAGE_HORIZONTAL_INSET, 
                                       frame.origin.y + (frame.size.height - imageViewHeight) / 2.0f,
                                       frame.size.width - 2 * CAS_IMAGE_HORIZONTAL_INSET, 
                                       imageViewHeight);
        
        if ([[self buttonTitleAtIndex:buttonIndex] length] > 0)
        {   
            //If both image and text present, show them as in simple UIButton
            CGFloat scaledImageWidth = buttonImage.size.width * imageViewHeight / buttonImage.size.height;
            scaledImageWidth = MIN(scaledImageWidth, frame.size.width - CAS_IMAGE_HORIZONTAL_INSET);
            
            CGFloat textWidth = [textLabel.text sizeWithFont:textLabel.font].width;
            
            if (textWidth  + scaledImageWidth > frame.size.width - CAS_IMAGE_HORIZONTAL_INSET * 2.0f)
                textLabel.hidden = YES; //If image is too big, then hide text
            else {
                //Centering image and text
                CGFloat totalWidth = scaledImageWidth + CAS_IMAGE_HORIZONTAL_INSET + textWidth;
            
                imageFrame.origin.x = round(3.0f + (frame.size.width - totalWidth) / 2.0f);
                imageFrame.size.width = scaledImageWidth;
                
                CGRect textFrame = textLabel.frame;
                textFrame.origin.x = round(3.0f + (frame.size.width + totalWidth) / 2.0f - textWidth);
                textFrame.size.width = textWidth;
                textLabel.frame = textFrame;
            }
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = buttonImage;
        [actionSheetButton addSubview:imageView];
        [imageView release];
    }
    
    
    [actionSheetButton addSubview:textLabel];
  
    //Add method to process button pressing
    [actionSheetButton addTarget:self 
                          action:@selector(highlightButton:) 
                forControlEvents:UIControlEventTouchDown];
    
    [actionSheetButton addTarget:self 
                          action:@selector(leaveButton:) 
                forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
}
 
//Show other colors, when button is touched down.
-(void)highlightButton:(UIView *)sender{
    CALayer *firstLayer = [[sender.layer  sublayers] objectAtIndex:0],
            *secondLayer = [[sender.layer sublayers] objectAtIndex:1];
    
    if ([secondLayer.name isEqualToString:@"hidden"])
        firstLayer.opacity = 0.0f;
    else
        secondLayer.opacity = 1.0f;
        
    UILabel *textLabel = [sender.subviews lastObject];
    textLabel.highlighted = YES;
}
     
//Show standart colors, when button is touched up.
-(void)leaveButton:(UIView *)sender{
    CALayer *firstLayer = [[sender.layer  sublayers] objectAtIndex:0],
            *secondLayer = [[sender.layer sublayers] lastObject];
    
    if ([secondLayer.name isEqualToString:@"hidden"])
        firstLayer.opacity = 1.0f;
    else
        secondLayer.opacity = 0.0f;
         
    UILabel *textLabel = [sender.subviews lastObject];
    textLabel.highlighted = NO;
}

-(void)initializeButtons{
    for (int buttonIndex=0; buttonIndex < [self numberOfButtons]; buttonIndex++)
        [self initializeButtonAtIndex:buttonIndex];
}

#pragma Show view functions 

//Add initialize buttons engine for all showing methods of superclass

-(void)showInView:(UIView *)view{
    [super showInView:view];
    
    [self initializeButtons];
}

-(void)showFromTabBar:(UITabBar *)view{
    [super showFromTabBar:view];
    
    [self initializeButtons];
}

-(void)showFromToolbar:(UIToolbar *)view{
    [super showFromToolbar:view];
    
    [self initializeButtons];
}

-(void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated{
    [super showFromRect:rect inView:view animated:animated];
    
    [self initializeButtons];
}

-(void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated{
    [super showFromBarButtonItem:item animated:animated];
    
    [self initializeButtons];
}

#pragma mark Button Attributes modifiing

//All atttributes for each button are stored in _buttonAttributes array.

-(id)valueOfAttribute:(NSString *)param forButtonAtIndex:(NSInteger)index{
    if (index > [self numberOfButtons])
        [NSException raise:@"Index out of range" format:@"Button index %d is out of range [0...%d]",
         index, [self numberOfButtons] - 1];
    
    if (index > [_buttonAttributes count])
        return NULL;
    else
        return [[_buttonAttributes objectAtIndex:index] objectForKey:param];
}

-(void)setValue:(id)value ofAttribute:(NSString *)param forButtonAtIndex:(NSInteger)index{
   if (index > [self numberOfButtons])
       [NSException raise:@"Index out of range" format:@"Button index %d is out of range [0...%d]",
        index, [self numberOfButtons] - 1];
    
    NSMutableDictionary *dict = [_buttonAttributes objectAtIndex:index];
    if (value == NULL)
        [dict removeObjectForKey:param];
    else
        [dict setObject:value forKey:param];
}

-(void)setFont:(UIFont *)font forButtonAtIndex:(NSInteger)index{
    [self setValue:font ofAttribute:@"font" forButtonAtIndex:index];
}
-(UIFont *)fontForButtonAtIndex:(NSInteger)index{
    return [self valueOfAttribute:@"font" forButtonAtIndex:index];
}

-(void)setColor:(UIColor *)color forButtonAtIndex:(NSInteger)index{
    [self setValue:color ofAttribute:@"color" forButtonAtIndex:index];
}

-(UIColor *)colorForButtonAtIndex:(NSInteger)index{
    return [self valueOfAttribute:@"color" forButtonAtIndex:index];
}

-(void)setPressedColor:(UIColor *)color forButtonAtIndex:(NSInteger)index{
    [self setValue:color ofAttribute:@"highlightedColor" forButtonAtIndex:index];  
}

-(UIColor *)pressedColorForButtonAtIndex:(NSInteger)index{
    return [self valueOfAttribute:@"highlightedColor" forButtonAtIndex:index];
}

-(void)setTextColor:(UIColor *)color forButtonAtIndex:(NSInteger)index{
    [self setValue:color ofAttribute:@"textColor" forButtonAtIndex:index];
}

-(UIColor *)textColorForButtonAtIndex:(NSInteger)index{
    return [self valueOfAttribute:@"textColor" forButtonAtIndex:index];
}

-(void)setPressedTextColor:(UIColor *)color forButtonAtIndex:(NSInteger)index{
    [self setValue:color ofAttribute:@"highlightedTextColor" forButtonAtIndex:index];
}

-(UIColor *)pressedTextColorForButtonAtIndex:(NSInteger)index{
    return [self valueOfAttribute:@"highlightedTextColor" forButtonAtIndex:index];
}

-(void)setImage:(UIImage *)image forButtonAtIndex:(NSInteger)index{
    [self setValue:image ofAttribute:@"image" forButtonAtIndex:index];
}

-(UIImage *)imageForButtonAtIndex:(NSInteger)index{
    return [self valueOfAttribute:@"image" forButtonAtIndex:index];
}

#pragma mark free memory

-(void)dealloc{
    [_buttonAttributes release];
    
    [super dealloc];
}

@end
