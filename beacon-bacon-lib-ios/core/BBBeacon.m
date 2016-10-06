//
// BBBeacon.m
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

#import "BBBeacon.h"

@implementation BBBeacon

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    if ([attributes isEqual:[NSNull null]]) {
        return nil;
    }
    self.beacon_id      = (NSUInteger)[[attributes valueForKeyPath:@"beacon_id"] integerValue] ;
    self.team_id        = (NSUInteger)[[attributes valueForKeyPath:@"team_id"] integerValue];
    self.place_id       = (NSUInteger)[[attributes valueForKeyPath:@"place_id"] integerValue];
    self.map_id         = (NSUInteger)[[attributes valueForKeyPath:@"map_id"] integerValue];

    self.name           = [attributes valueForKeyPath:@"name"];
    self.beacon_description = [attributes valueForKeyPath:@"description"];

    self.beacon_uid     = [attributes valueForKeyPath:@"beacon_uid"];
    self.proximity_uuid = [attributes valueForKeyPath:@"proximity_uuid"];

    self.major          = (NSUInteger)[[attributes valueForKeyPath:@"major"] integerValue];
    self.minor          = (NSUInteger)[[attributes valueForKeyPath:@"minor"] integerValue];
    
    self.accuracyDataPoints = [NSMutableArray new];
    
    return self;
}

- (BOOL) majorMinorMacthing:(CLBeacon *)clbeacon {
    return self.major == [clbeacon.major integerValue] && self.minor == [clbeacon.minor integerValue];
}

@end
