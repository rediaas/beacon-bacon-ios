//
// BBConfig.h
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

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import <UIKit/UIKit.h>
#import "BBDataManager.h"

@interface BBConfig : NSObject

#define BB_API_KEY  @"INSERT_YOUR_API_KEY_HERE"
#define BB_BASE_URL @"https://beaconbacon.nosuchagency.com/api/v1/"

#define BB_STORE_KEY_CURRENT_PLACE_ID   @"BB_STORE_KEY_CURRENT_PLACE_ID"
#define BB_STORE_KEY_CUSTOM_COLOR       @"BB_STORE_KEY_CUSTOM_COLOR"
#define BB_STORE_KEY_REGULAR_FONT       @"BB_STORE_KEY_REGULAR_FONT"
#define BB_STORE_KEY_LIGHT_FONT         @"BB_STORE_KEY_LIGHT_FONT"

@property (nonatomic, strong) NSString *currentPlaceId;
@property (nonatomic, strong) UIColor  *customColor;

@property (nonatomic, strong) UIFont  *regularFont;
@property (nonatomic, strong) UIFont  *lightFont;

+ (instancetype)sharedConfig;

-(UIFont *)regularFontWithSize:(CGFloat)size;
-(UIFont *)lightFontWithSize:(CGFloat)size;

- (void) setupWithPlaceIdentifier:(NSString *)identifier withCompletion:(void (^)(NSString *placeIdentifier, NSError *error))completionBlock;

@end
