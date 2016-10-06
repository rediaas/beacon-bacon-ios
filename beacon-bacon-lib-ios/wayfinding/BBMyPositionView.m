//
// BBMyPositionView.m
//
// Copyright (c) 2016 Mustache ApS
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "BBMyPositionView.h"

@implementation BBMyPositionView {
   
    UIView *myPosistionView;
    
    UIImageView *myPositionImageView;
    
    UIView *pulseView;
    
    BOOL pulseOut;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, BB_MY_POSITION_WIDTH, BB_MY_POSITION_WIDTH)];
    if (!self) {
        return nil;
    }
    self.backgroundColor = [UIColor clearColor];
    
    UIColor *color = [[BBConfig sharedConfig] customColor];
    
    if (pulseView == nil) {
        pulseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BB_MY_POSITION_WIDTH, BB_MY_POSITION_WIDTH)];
        
        pulseView.backgroundColor = [color colorWithAlphaComponent:0.2];
        pulseView.layer.cornerRadius = BB_MY_POSITION_WIDTH/2;
        [self addSubview:pulseView];
    }
    
    if (myPosistionView == nil) {
        CGFloat insetXY = BB_MY_POSITION_WIDTH/2 - BB_MY_POSITION_INDICATOR_WIDTH/2;
        myPosistionView = [[UIView alloc] initWithFrame:CGRectMake(insetXY, insetXY, BB_MY_POSITION_INDICATOR_WIDTH, BB_MY_POSITION_INDICATOR_WIDTH)];
        myPosistionView.backgroundColor = color;
        myPosistionView.layer.cornerRadius = BB_MY_POSITION_INDICATOR_WIDTH/2;
        myPosistionView.layer.masksToBounds = YES;
        myPosistionView.layer.borderColor = [[UIColor whiteColor] CGColor];
        myPosistionView.layer.borderWidth = 2.f;
        [self addSubview:myPosistionView];
    }
    
    if (myPositionImageView == nil) {
        CGFloat insetXY = BB_MY_POSITION_INDICATOR_WIDTH/2 - BB_MY_POSITION_ICON_WIDTH/2;
        myPositionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(insetXY, insetXY, BB_MY_POSITION_ICON_WIDTH, BB_MY_POSITION_ICON_WIDTH)];
        myPositionImageView.contentMode = UIViewContentModeScaleAspectFit;
        myPositionImageView.image = [[UIImage imageNamed:@"position-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        myPositionImageView.tintColor = [UIColor whiteColor];
        [myPosistionView addSubview:myPositionImageView];
    }

    
    return self;
}

- (void) addPulsatingAnimation {
    if (pulseView.layer.animationKeys.count > 0) {
        return;
    }
    CABasicAnimation *pulseViewScaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseViewScaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    pulseViewScaleAnimation.duration = 1.6;
    pulseViewScaleAnimation.repeatCount = HUGE_VAL;
    pulseViewScaleAnimation.autoreverses = YES;
    pulseViewScaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    pulseViewScaleAnimation.toValue = [NSNumber numberWithFloat:0.8];
    [pulseView.layer addAnimation:pulseViewScaleAnimation forKey:@"scale"];
}

@end
