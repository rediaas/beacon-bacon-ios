//
// BBPOIFloor.m
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

#import "BBFloor.h"

@implementation BBFloor

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.floor_id = (NSUInteger)[[attributes valueForKeyPath:@"id"] integerValue];
    self.team_id = (NSUInteger)[[attributes valueForKeyPath:@"team_id"] integerValue];
    self.name = [attributes valueForKeyPath:@"name"];
    
    self.order = (NSUInteger)[[attributes valueForKeyPath:@"order"] integerValue];

    self.image_url = [attributes valueForKeyPath:@"image"];

    NSMutableArray *tmpPOILocations = [NSMutableArray new];
    NSMutableArray *tmpBeaconLocations = [NSMutableArray new];
    for (NSDictionary *locationDict in [attributes valueForKeyPath:@"locations"]) {
        if ([locationDict[@"type"] isEqualToString:@"poi"]) {
            BBPOILocation *location = [[BBPOILocation alloc] initWithAttributes:locationDict];
            [tmpPOILocations addObject:location];
        } else if ([locationDict[@"type"] isEqualToString:@"beacon"]) {
            BBBeaconLocation *location = [[BBBeaconLocation alloc] initWithAttributes:locationDict];
            [tmpBeaconLocations addObject:location];
        } else if ([locationDict[@"type"] isEqualToString:@"ims"]) {
            // Ignore all IMS
        } else {
            // Unknown Type - ingnore at this point (until supported)
        }

    }
    self.poiLocations = tmpPOILocations;
    self.beaconLocations = tmpBeaconLocations;
    
    self.map_width_in_centimeters = (NSUInteger)[[attributes valueForKeyPath:@"map_width_in_centimeters"] integerValue];
    self.map_height_in_centimeters = (NSUInteger)[[attributes valueForKeyPath:@"map_height_in_centimeters"] integerValue];
    self.map_width_in_pixels = (NSUInteger)[[attributes valueForKeyPath:@"map_width_in_pixels"] integerValue];
    self.map_height_in_pixels = (NSUInteger)[[attributes valueForKeyPath:@"map_height_in_pixels"] integerValue];
    
    self.map_pixel_to_centimeter_ratio = self.map_width_in_pixels / self.map_width_in_centimeters;
    self.map_walkable_color = [attributes valueForKeyPath:@"map_walkable_color"];
    
    return self;
}

- (void) getFloorplanImage:(void (^)(UIImage* result, NSError* error))completionBlock {
    if (self.image_url == nil) {
        completionBlock(nil, nil);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.image_url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error == nil){
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (image == nil) {
                completionBlock(nil, nil);
            } else {
                completionBlock(image, nil);
            }

        } else {
            completionBlock(nil, error);
        }
    }];
}

- (BBBeaconLocation *) matchingBBBeacon:(CLBeacon *)clbeacon {
    for (BBBeaconLocation *beaconLocation in self.beaconLocations) {
        if ([beaconLocation.beacon majorMinorMacthing:clbeacon]) {
            return beaconLocation;
        }
    }
    return nil;
}

- (void) clearAllAccuracyDataPoints {
    for (BBBeaconLocation *beaconLocation in self.beaconLocations) {
        beaconLocation.beacon.accuracyDataPoints = [NSMutableArray new];
    }
}

@end
