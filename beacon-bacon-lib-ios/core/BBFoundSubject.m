//
// BBFoundSubject.m
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

#import "BBFoundSubject.h"

@implementation BBFoundSubject

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if ([attributes isEqual:[NSNull null]]) {
        return nil;
    }
    
    if ([attributes objectForKey:@"status"]) {
        self.status = [attributes objectForKey:@"status"];
    }
    
    if ([attributes objectForKey:@"data"]) {
        NSDictionary *data = [attributes objectForKey:@"data"];

        if (![data isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        if ([data objectForKey:@"floor"]) {
            NSDictionary *floorDict = [data objectForKey:@"floor"];

            if ([floorDict objectForKey:@"id"]) {
                self.floor_id = (NSUInteger)[[floorDict objectForKey:@"id"] integerValue];
            }
        }

        if ([data objectForKey:@"location"]) {
            NSDictionary *locationDict = [data objectForKey:@"location"];

            if ([locationDict valueForKeyPath:@"id"]) {
                self.location_id = (NSUInteger)[[locationDict objectForKey:@"id"] integerValue];
            }
            if ([locationDict valueForKeyPath:@"posX"]) {
                self.location_posX = (NSUInteger)[[locationDict objectForKey:@"posX"] integerValue];
            }
            if ([locationDict valueForKeyPath:@"posY"]) {
                self.location_posY = (NSUInteger)[[locationDict objectForKey:@"posY"] integerValue];
            }
        }
    }
    
    return self;
}

- (BOOL)isSubjectFound {
    return [self.status isEqualToString:BBStatus_Found];
}

@end
