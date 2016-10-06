//
// BBPOIAreaMapView.m
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

#import "BBPOIAreaMapView.h"

@interface BBPOIAreaMapView() {
    UILabel *nameLabel;
}

@end

@implementation BBPOIAreaMapView

- (id) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    return self;
}

-(void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (nameLabel == nil && !self.areaTitleVisible) {
        self.areaTitleVisible = YES;
        
        CGRect labelRect = [self.areaTitle boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [[BBConfig sharedConfig] lightFontWithSize:14] } context:nil];

        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelRect.size.width + 32, labelRect.size.height + 16)];
        nameLabel.text = self.areaTitle;
        nameLabel.font = [[BBConfig sharedConfig] lightFontWithSize:14];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        
        nameLabel.clipsToBounds = NO;
        
        [nameLabel.layer setShadowOffset:CGSizeMake(0, 5)];
        [nameLabel.layer setShadowOpacity:0.1f];
        [nameLabel.layer setShadowRadius:2.5f];
        [nameLabel.layer setShouldRasterize:NO];
        [nameLabel.layer setShadowColor:[[UIColor blackColor] CGColor]];
        
        UIImageView *triangle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowtriangle"]];
        triangle.frame = CGRectMake(nameLabel.frame.size.width/2 - triangle.frame.size.width/2, nameLabel.frame.size.height, triangle.frame.size.width, triangle.frame.size.height);
        [nameLabel addSubview:triangle];

        CGPoint touchPoint = [[touches anyObject] locationInView:self];
        nameLabel.center = CGPointMake(touchPoint.x, touchPoint.y - labelRect.size.height/2 - triangle.frame.size.height);
        
        [self addSubview:nameLabel];
    } else {
        self.areaTitleVisible = NO;
        if (nameLabel != nil) {
            [nameLabel removeFromSuperview];
            nameLabel = nil;
        }
    }
}

@end
