//
//  ViewController.m
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

#import "ViewController.h"
#import "UICustomActionSheet.h"
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/256.0f green:(g)/256.0f blue:(b)/256.0f alpha:1.0f]


@implementation ViewController

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

-(IBAction)simpleSample{
    UIActionSheet *sheet = [[UICustomActionSheet alloc] initWithTitle:@"It's just boring UIActionSheet"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Standart Cancel Button"
                                                     destructiveButtonTitle:@"Standart Destructive Button"
                                                          otherButtonTitles:@"Standart Button", 
                                  @"Standart Button", 
                                  @"Standart Button", nil];
    
    [sheet showFromTabBar:tabBar];
    [sheet addButtonWithTitle:@"Some title"];
    
    [sheet autorelease];
}

-(IBAction)test1:(id)sender{
    UICustomActionSheet *sheet = [[UICustomActionSheet alloc] initWithTitle:@"RGB Test"
                                                       delegate:self 
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Red", @"Green", @"Blue", nil];
    
    [sheet setColor:RGBCOLOR(200, 0, 0) forButtonAtIndex:0];
    [sheet setColor:RGBCOLOR(0, 200, 0) forButtonAtIndex:1];
    [sheet setColor:RGBCOLOR(0, 0, 200) forButtonAtIndex:2];
    
    [sheet setPressedColor:[UIColor redColor] forButtonAtIndex:0];
    [sheet setPressedColor:[UIColor greenColor] forButtonAtIndex:1];
    [sheet setPressedColor:[UIColor blueColor] forButtonAtIndex:2];
    
    
    [sheet setPressedTextColor:RGBCOLOR(250, 200, 200) forButtonAtIndex:0];
    [sheet setPressedTextColor:RGBCOLOR(200, 250, 200) forButtonAtIndex:1];
    [sheet setPressedTextColor:RGBCOLOR(200, 200, 250) forButtonAtIndex:2];
    
    [sheet setFont:[UIFont fontWithName:@"Arial" size:22.0f] forButtonAtIndex:0];
    [sheet setFont:[UIFont italicSystemFontOfSize:21.0f] forButtonAtIndex:1];

        
    for (int i=0; i < 3; i++)
    {
        [sheet setTextColor:[UIColor whiteColor] forButtonAtIndex:i];
    }
    
    [sheet showFromRect:[sender frame] inView:self.view animated:YES];
    
    [sheet autorelease];
}


-(IBAction)test2{
    UICustomActionSheet *sheet = [[UICustomActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"Standart Cancel Button"
                                                     destructiveButtonTitle:@"Standart Destructive Button"
                                                          otherButtonTitles:@"Standart Button", 
                                                                @"Facebook style", 
                                                                @"Twitter style", nil];

    
    [sheet setColor:RGBCOLOR(55, 85, 155) forButtonAtIndex:2];
    [sheet setColor:RGBCOLOR(60, 190, 200) forButtonAtIndex:3];
    
    [sheet setTextColor:[UIColor whiteColor] forButtonAtIndex:2];
    [sheet setTextColor:[UIColor whiteColor] forButtonAtIndex:3];

    
    
    [sheet setImage:[UIImage imageNamed:@"Facebook.png"] forButtonAtIndex:2];
    [sheet setImage:[UIImage imageNamed:@"twitter.png"] forButtonAtIndex:3];
    
    [sheet showFromTabBar:tabBar];
    
    [sheet autorelease];
}


-(IBAction)test3{
    UICustomActionSheet *sheet = [[UICustomActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"Modified Cancel Button"
                                                     destructiveButtonTitle:@"Modified Destructive Button"
                                                          otherButtonTitles:@"Standart Button", 
                                  @"Facebook style", 
                                  @"Twitter style", nil];
    
    
    [sheet setColor:RGBCOLOR(55, 85, 155) forButtonAtIndex:2];
    [sheet setColor:RGBCOLOR(60, 190, 200) forButtonAtIndex:3];
    
    [sheet setTextColor:[UIColor whiteColor] forButtonAtIndex:2];
    [sheet setTextColor:[UIColor whiteColor] forButtonAtIndex:3];
    
    [sheet setImage:[UIImage imageNamed:@"Facebook.png"] forButtonAtIndex:2];
    [sheet setImage:[UIImage imageNamed:@"twitter.png"] forButtonAtIndex:3];
    
    [sheet setFont:[UIFont italicSystemFontOfSize:20.0f] forButtonAtIndex:0];
    [sheet setTextColor:[[UIColor orangeColor] colorWithAlphaComponent:0.8f] forButtonAtIndex:4];
    
    UIColor *myColor = RGBCOLOR(200, 100, 0);
    for (int i=1; i<=7; i++)
    {
        [sheet addButtonWithTitle:[NSString stringWithFormat:@"Additional Button %d", i]];
        
        [sheet setColor:[myColor colorWithAlphaComponent:1.0f - 0.1f * i] forButtonAtIndex:i + 4];
        [sheet setPressedColor:[UIColor orangeColor] forButtonAtIndex:i + 4];
        [sheet setPressedTextColor:[UIColor whiteColor] forButtonAtIndex:i + 4];
    }
    
    [sheet setColor:[UIColor whiteColor] forButtonAtIndex:[sheet destructiveButtonIndex]];
    [sheet setColor:[UIColor blackColor] forButtonAtIndex:[sheet cancelButtonIndex]];
    
    [sheet showFromTabBar:tabBar];
    
    [sheet autorelease];
}

-(IBAction)showStandardUIActionSheet{
    UIActionSheet *basicSheet = [[UIActionSheet alloc] initWithTitle:@"DefaultTitle"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel Button"
                                              destructiveButtonTitle:@"Desctructive Button"
                                                   otherButtonTitles:@"Button 1", @"Button 2", nil];
    
    
    [basicSheet showFromTabBar:tabBar];
    [basicSheet autorelease];
}

#pragma mark UIActionSheetDelegate methods

-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex != -1)
        statusLabel.text = [NSString stringWithFormat:@"Pressed: %@", 
                            [actionSheet buttonTitleAtIndex:buttonIndex]];
}

#pragma mark free memory

-(void)dealloc
{
    [tabBar release];
    [statusLabel release];
    
    [super dealloc];
}

@end
