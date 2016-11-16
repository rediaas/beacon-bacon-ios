//
// BBPlace.m
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

#import "BBPlace.h"

@implementation BBPlace

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.identifier     = [attributes valueForKeyPath:@"identifier"];
    self.place_id       = (NSUInteger)[[attributes valueForKeyPath:@"id"] integerValue];
    self.team_id        = (NSUInteger)[[attributes valueForKeyPath:@"team_id"] integerValue];
    self.name           = [attributes valueForKeyPath:@"name"];
    
    self.address        = [attributes valueForKeyPath:@"address"];
    self.zipcode        = [attributes valueForKeyPath:@"zipcode"];
    self.city           = [attributes valueForKeyPath:@"city"];

    self.order           = (NSUInteger)[[attributes valueForKeyPath:@"order"] integerValue];

    NSMutableArray *tmpFloors = [NSMutableArray new];
    for (NSDictionary *floorDict in [attributes valueForKeyPath:@"floors"]) {
        BBFloor *floor = [[BBFloor alloc] initWithAttributes:floorDict];
        [tmpFloors addObject:floor];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    self.floors = [tmpFloors sortedArrayUsingDescriptors:sortDescriptors];
    
    self.beacon_positioning_enabled = (NSUInteger)[[attributes valueForKeyPath:@"beacon_positioning_enabled"] integerValue];
    self.beacon_proximity_enabled   = (NSUInteger)[[attributes valueForKeyPath:@"beacon_proximity_enabled"] integerValue];

    return self;
}

- (BBFloor *) matchingBBFloor:(CLBeacon *)clbeacon {
    for (BBFloor *floor in self.floors) {
        for (BBBeaconLocation *beaconLocation in floor.beaconLocations) {
            if ([beaconLocation.beacon majorMinorMacthing:clbeacon]) {
                return floor;
            }
        }
    }
    return nil;
}

@end
