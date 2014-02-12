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
#define DEFAULT_TABLE_VIEW_CELL_HEIGHT_OLD 54.0f
#define DEFAULT_TABLE_VIEW_CELL_HEIGHT_IOS7 44.0f
#define DEFAULT_TABLE_VIEW_CELL_HEIGHT (_isFlatDesign ? DEFAULT_TABLE_VIEW_CELL_HEIGHT_IOS7 : DEFAULT_TABLE_VIEW_CELL_HEIGHT_OLD)
#define WINDOW_WIDTH 320.0f
#define IOS7_RECT_MARGIN 8.0f
#define IOS7_BUTTON_ALPHA_COMPONENT 0.9f
#define NUMBER_OF_BUTTONS_FOR_TABLE 5

#ifndef SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#endif

@interface  UICustomActionSheet(Private)
-(id)valueOfAttribute:(NSString *)param forButtonAtIndex:(NSInteger)index;
-(void)setValue:(id)value ofAttribute:(NSString *)param forButtonAtIndex:(NSInteger)index;
-(BOOL)isTableViewDisplayed;

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
    NSInteger index;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        index = [super addButtonWithTitle:title];
    else
        index = [super addButtonWithTitle:@""];
    
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

#pragma mark Table View check

-(BOOL)isTableViewDisplayed{
    return [self numberOfButtons] >= NUMBER_OF_BUTTONS_FOR_TABLE && !_isIpad;
}

#pragma mark Customize button methods

-(UILabel *)textLabelForButton:(UIView *)actionSheetButton atIndex:(NSInteger)buttonIndex{
    UILabel *textLabel = [[UILabel alloc] initWithFrame:actionSheetButton.bounds];
    textLabel.shadowOffset = CGSizeMake(0.0f, -0.1f);
    textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    textLabel.text = [self buttonTitleAtIndex:buttonIndex];
    textLabel.textAlignment = NSTextAlignmentCenter;
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

-(void)initializeImageForButton:(UIView *)actionSheetButton 
                      withLabel:(UILabel *)textLabel
                          frame:(CGRect) frame
                        atIndex:(NSInteger)buttonIndex
{
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
            
            UIFont *font = textLabel.font;
            NSString *text = textLabel.text;
            CGFloat textWidth = [text sizeWithFont:font].width;
            if (textWidth == 0)
            {
                font = [UIFont boldSystemFontOfSize:20.0f];
                textWidth = [text sizeWithFont:font].width;
            }
            
            if (textWidth  + scaledImageWidth > frame.size.width - CAS_IMAGE_HORIZONTAL_INSET * 2.0f)
                textLabel.hidden = YES; //If image is too big, then hide text
            else {
                //Centering image and text
                CGFloat totalWidth = scaledImageWidth + CAS_IMAGE_HORIZONTAL_INSET + textWidth;
                
                imageFrame.origin.x = round(3.0f + (frame.size.width - totalWidth) / 2.0f);
                imageFrame.size.width = scaledImageWidth;
                
                if ([actionSheetButton isKindOfClass:[UITableViewCell class]])
                {                    
                    //If function is used for UITableViewCell than we cannot modify textLabel frame
                    //Instead of this we will add whitespaces to move text and do not overlap with the image
                    
                    while (textWidth < totalWidth)
                    {
                        text = [@" " stringByAppendingString:text];
                        textWidth = [text sizeWithFont:font].width;
                    }
                    
                    textLabel.text = text;
                }
                else
                {
                    //Change textLabel frame to not overlap with the image
                    CGRect textFrame = textLabel.frame;
                    textFrame.origin.x = round(3.0f + (frame.size.width + totalWidth) / 2.0f - textWidth);
                    textFrame.size.width = textWidth;
                    textLabel.frame = textFrame;
                }
            }
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = buttonImage;
        imageView.tag = 10.0f;
        [actionSheetButton addSubview:imageView];
        [imageView release];
    }    
}

-(NSArray *)gradientColorsArrayForColor:(UIColor *)color{
    if (color == NULL)
        return NULL;
    else
        return [NSArray arrayWithObjects:
                        (id)[color colorWithAlphaComponent:0.4f].CGColor,
                        (id)[color colorWithAlphaComponent:0.7f].CGColor,
                        (id)[color colorWithAlphaComponent:1.0f].CGColor,
                        (id)[color colorWithAlphaComponent:0.85f].CGColor,
                        nil];
};

-(CAGradientLayer *)buttonLayerWithFrame:(CGRect)frame andColor:(UIColor *)color{
    BOOL isIpad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.frame = frame;
    gradientLayer.masksToBounds = YES;
    gradientLayer.cornerRadius = isIpad ? 4.0f : 8.5f;
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:0.5f],
                               [NSNumber numberWithFloat:0.5f],
                               [NSNumber numberWithFloat:1.0f],
                               nil];
    
    gradientLayer.colors = [self gradientColorsArrayForColor:color];
    gradientLayer.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f].CGColor;
    gradientLayer.opacity = (CGFloat)(color != NULL);
    
    return [gradientLayer autorelease];
}

-(void)initializeButtonAtIndexForSquaroDesign:(NSInteger)buttonIndex{
    BOOL titlePresent = (self.title != NULL);
    UIButton *actionSheetButton = (UIButton *)[self.subviews objectAtIndex:buttonIndex + titlePresent];
    [actionSheetButton.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [actionSheetButton.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    CGRect frame = actionSheetButton.bounds;
    
    if (!_isIpad)
        frame = CGRectMake(3.2f, 3.0f,
                           actionSheetButton.frame.size.width - 6.0f,
                           actionSheetButton.frame.size.height - 7.0f);
    
    
    UIColor *gradientColor = [self colorForButtonAtIndex:buttonIndex];
    CAGradientLayer *bgLayer = [self buttonLayerWithFrame:frame andColor:gradientColor];
    [actionSheetButton.layer insertSublayer:bgLayer atIndex:0];
    
    //Add new text color
    UILabel *textLabel = [self textLabelForButton:actionSheetButton atIndex:buttonIndex];
    
    [self initializeImageForButton:actionSheetButton
                         withLabel:textLabel
                             frame:frame
                           atIndex:buttonIndex];
    
    [actionSheetButton addSubview:textLabel];
    
    //Add method to process button pressing
     [actionSheetButton addTarget:self
     action:@selector(highlightButton:)
     forControlEvents:UIControlEventTouchDown];
     
     [actionSheetButton addTarget:self
     action:@selector(leaveButton:)
     forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
}

- (UIImage *)imageWithColor:(UIColor *)color{
    if (color == NULL) return NULL;
    
    CGRect rect = CGRectMake(0, 0, WINDOW_WIDTH, 1);
    CGFloat margin = _isIpad ? 0.0f : IOS7_RECT_MARGIN;
    CGRect fillRect = CGRectMake(margin, 0,
                                 WINDOW_WIDTH - 2 * margin, 1.0f);
    
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    UIColor *fillColor = [color colorWithAlphaComponent:IOS7_BUTTON_ALPHA_COMPONENT];
    [fillColor setFill];
    UIRectFill(fillRect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)setRoundingCorners:(UIRectCorner)roundingCorner forButton:(UIButton *)actionButton{
    CGRect maskRect = [actionButton bounds];
    maskRect.origin.x += IOS7_RECT_MARGIN;
    maskRect.size.width -= 2 * IOS7_RECT_MARGIN;
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:maskRect byRoundingCorners:roundingCorner
                                           cornerRadii:CGSizeMake(3.5, 3.5)];
    
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = actionButton.bounds;
    maskLayer.path = maskPath.CGPath;
    actionButton.layer.mask = maskLayer;
    [maskLayer release];
}


-(void)initializeButtonAtIndexForFlatDesign:(NSInteger)buttonIndex{
    
    BOOL titlePresent = (self.title != NULL);
    NSInteger flatButtonIndex =  (_isIpad ? 0 : 1) + buttonIndex + titlePresent;
    UIButton *actionSheetButton = (UIButton *)[self.subviews objectAtIndex:flatButtonIndex];
    
    for (UIView *subview in actionSheetButton.subviews) {
        NSLog(@"Current subiview: %@", subview);
    }
    
    UIFont *textFont = [self fontForButtonAtIndex:buttonIndex];
    //If font is not customized use standart font of UIActionSheet
    if (textFont != NULL)
        actionSheetButton.titleLabel.font = textFont;
    
    UIColor *textColor = [self textColorForButtonAtIndex:buttonIndex];
    if (textColor != NULL)
        [actionSheetButton setTitleColor:textColor forState:UIControlStateNormal];
    
    UIColor *highlightedTextColor = [self pressedTextColorForButtonAtIndex:buttonIndex];
    if (highlightedTextColor == NULL)
        [actionSheetButton setTitleColor:highlightedTextColor forState:UIControlStateSelected];
    
    UIImage *image = [self  imageForButtonAtIndex:buttonIndex];
    if (image != NULL) {
        if (image.size.height > actionSheetButton.bounds.size.height) {
            image = [UIImage imageWithCGImage:[image CGImage]
                                scale:(image.scale * image.size.height / actionSheetButton.bounds.size.height)
                          orientation:(image.imageOrientation)];
        }
        
        [actionSheetButton setImage:image forState:UIControlStateNormal];
        [actionSheetButton setImageEdgeInsets:UIEdgeInsetsMake(.0f, .0f, .0f, 20.0f)];
        actionSheetButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    UIColor *backgroundColor = [self colorForButtonAtIndex:buttonIndex];
    if (backgroundColor != NULL)
    {
        UIImage *backgroundImage = [self imageWithColor:backgroundColor];
        [actionSheetButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    }
    
    UIColor *selectedColor = [self pressedColorForButtonAtIndex:buttonIndex];
    if (selectedColor != NULL){
        UIImage *selectedBackgroud = [self imageWithColor:selectedColor];
        [actionSheetButton setBackgroundImage:selectedBackgroud forState:UIControlStateSelected];
    }
    
    if (backgroundColor != NULL || selectedColor != NULL) {
       // [actionSheetButton setContentEdgeInsets:UIEdgeInsetsMake(1.0f, 20.0f, 1.0f, 20.0f)];
        
        if (!_isIpad){
            if (buttonIndex == [self cancelButtonIndex]) {
                [self setRoundingCorners:UIRectCornerAllCorners
                               forButton:actionSheetButton];
            }
            else if (([self isTableViewDisplayed] && buttonIndex == [self destructiveButtonIndex])
                     || (titlePresent && buttonIndex == 0)){
                [self setRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                               forButton:actionSheetButton];
            }
            else if (buttonIndex == self.numberOfButtons - 1 ||
                     (buttonIndex == self.numberOfButtons - 2 && self.cancelButtonIndex == self.numberOfButtons - 1))
            {
                [self setRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                               forButton:actionSheetButton];
            }
        }
    }
}

-(void)initializeButtonAtIndex:(NSInteger)buttonIndex{
    if (_isFlatDesign)
        [self initializeButtonAtIndexForFlatDesign:buttonIndex];
    else
        [self initializeButtonAtIndexForSquaroDesign:buttonIndex];
}
 
//Show other colors, when button is touched down.
-(void)highlightButton:(UIView *)sender{
    BOOL titlePresent = (self.title != NULL);
    NSInteger index = [self.subviews indexOfObject:sender] - titlePresent;
    
    CAGradientLayer *gradientLayer = (CAGradientLayer *)[[sender.layer  sublayers] objectAtIndex:0];
    
    UIColor *color = [self pressedColorForButtonAtIndex:index];
    if ([gradientLayer isKindOfClass:[CAGradientLayer class]])
        gradientLayer.colors = [self gradientColorsArrayForColor:color];
    gradientLayer.opacity = (CGFloat)(color != NULL);
    
    UILabel *textLabel = [sender.subviews lastObject];
    textLabel.highlighted = YES;
}
     
//Show standart colors, when button is touched up.
-(void)leaveButton:(UIView *)sender{
    BOOL titlePresent = (self.title != NULL);
    NSInteger index = [self.subviews indexOfObject:sender] - titlePresent;
    
    CAGradientLayer *gradientLayer = (CAGradientLayer *)[[sender.layer  sublayers] objectAtIndex:0];
    UIColor *color = [self pressedColorForButtonAtIndex:index];
    gradientLayer.colors = [self gradientColorsArrayForColor:color];
    gradientLayer.opacity = (CGFloat)(color != NULL);
         
    UILabel *textLabel = [sender.subviews lastObject];
    textLabel.highlighted = NO;
}

-(void)initializeButtons{
    _isFlatDesign = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0");
    _isIpad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    
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

#pragma mark UITableView delegate methods

//If buttons are too many, then UIActionSheet creates table.
//Instead of standart buttons UITableViewCell objects are used.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        //If there is flat design, than table frame should be updated to be the same size
        //as th rounded rect of UIActionSheet
        CGRect tableViewFrame = tableView.frame;
        tableViewFrame.origin.y -= 10.0f;
        tableViewFrame.size.height += 20.0f;
        [tableView setFrame:tableViewFrame];
    }
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"UICustomActionSheet cell %d";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:identifier];
          
    //Add two color border to table
    CGRect frame = CGRectMake(0.0f, DEFAULT_TABLE_VIEW_CELL_HEIGHT-1.0f, tableView.frame.size.width, 1.0f);
    UIView *borderView1 = [[UIView alloc] initWithFrame:frame];
    borderView1.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5f];
    [cell.contentView addSubview:borderView1];
    [borderView1 release];
    
    frame.origin.y = DEFAULT_TABLE_VIEW_CELL_HEIGHT;
    UIView *borderView2 = [[UIView alloc] initWithFrame:frame];
    borderView2.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
    [cell.contentView addSubview:borderView2];
    [borderView2 release];
    
    //Add twocolor border in the top if it is first cell
    if (indexPath.row == 0)
    {
        frame.origin.y = 0.0f;
        UIView *borderView3 = [[UIView alloc] initWithFrame:frame];
        borderView3.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5f];
        [cell.contentView addSubview:borderView3];
        [borderView3 release];
        
        frame.origin.y = 1.0f;
        UIView *borderView4 = [[UIView alloc] initWithFrame:frame];
        borderView4.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
        [cell.contentView addSubview:borderView4];
        [borderView4 release];
    }   
    
    return [cell autorelease];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell 
    forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger buttonIndex = indexPath.row;
    
    //If table is present, than it contains neither destructive button nor cancel button.
    //This buttons are showing as usual but should ignore them, when they are showing.
    // That's why buttonIndex is incremented.
    
    if (self.destructiveButtonIndex != -1 && buttonIndex >= self.destructiveButtonIndex)
        buttonIndex++;
    
    if (self.cancelButtonIndex != -1 && buttonIndex >= self.cancelButtonIndex)
        buttonIndex++;
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = [self buttonTitleAtIndex:buttonIndex];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    //Set background color for cell
    UIColor *backgroundColor = [self colorForButtonAtIndex:buttonIndex];
    if (backgroundColor != NULL)
    {
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = backgroundColor;
        cell.backgroundView = backgroundView;
        [backgroundView release];
        
    }
    else
        cell.backgroundView = NULL;
    
    //Set pressed color when cell is selected
    UIColor *selectedBackgroundColor = [self pressedColorForButtonAtIndex:buttonIndex];
    if (selectedBackgroundColor != NULL)
    {
        UIView *selectedBackgroundView = [[UIView alloc] init];
        selectedBackgroundView.backgroundColor = selectedBackgroundColor;
        cell.selectedBackgroundView = selectedBackgroundView;
        [selectedBackgroundView release];
    }
    else
        cell.selectedBackgroundView = NULL;
    
    //Change  cell font
    UIFont *textFont = [self fontForButtonAtIndex:buttonIndex];
    if (textFont != NULL)
        cell.textLabel.font = textFont;
    
    //Change cell text color
    UIColor *textColor = [self textColorForButtonAtIndex:buttonIndex];
    if (textColor != NULL)
        cell.textLabel.textColor = textColor;
    
    //Set cell textcolor when it is pressed
    UIColor *highlightedTextColor = [self pressedTextColorForButtonAtIndex:buttonIndex];
    if (highlightedTextColor == NULL)
        cell.textLabel.highlightedTextColor = highlightedTextColor;
    
    //Add image for cell, if needed
    CGRect cellFrame = CGRectMake(0.0f, 0.0f, tableView.frame.size.width, DEFAULT_TABLE_VIEW_CELL_HEIGHT);
    [self initializeImageForButton:cell withLabel:cell.textLabel frame:cellFrame atIndex:buttonIndex];    
}

#pragma mark free memory

-(void)dealloc{
    [_buttonAttributes release];
    
    [super dealloc];
}

@end
