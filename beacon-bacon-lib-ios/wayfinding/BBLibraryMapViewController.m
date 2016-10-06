//
// BBLibraryMapViewController.m
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

#import "BBLibraryMapViewController.h"

@interface BBLibraryMapViewController() <CBCentralManagerDelegate>

@property (nonatomic) CBCentralManager *bluetoothManager;
@end


@implementation BBLibraryMapViewController {
    
    double scaleRatio;
    
    UIPinchGestureRecognizer *pinchGestureRecognizer;
    
    UIImageView *floorplanImageView; // BB_MAP_TAG_FLOORPLAN
    BBMyPositionView *myCurrentLocationView;   // BB_MAP_TAG_MY_POSITION
    
    CGPoint myCoordinate;
    
    BBPlace *place;
    BBFloor *currentDisplayFloorRef;
    
    // When ranging beacons we want to know which floor the user is located at
    BBFloor *rangedBeconsFloorRef;
    
    BBLibraryMapPOIViewController *currentPOIViewController;
    
    BOOL zoomToUserPosition;
    
    BOOL showMaterialView;
    BOOL showMyPositionView;
    
    BBPopupView *popupView;
    BOOL foundSubjectPopopViewDisplayed;

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) applyRoundAndShadow:(UIView *)view {
    
    [view.layer setShadowOffset:CGSizeMake(0, 5)];
    [view.layer setShadowOpacity:0.1f];
    [view.layer setShadowRadius:2.5f];
    [view.layer setShouldRasterize:NO];
    [view.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [view.layer setCornerRadius:view.frame.size.width/2];
    
    [view.layer setShadowPath: [[UIBezierPath bezierPathWithRoundedRect:[view bounds] cornerRadius:view.frame.size.width/2] CGPath]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    scaleRatio = 1.00f;
    zoomToUserPosition = false;
    foundSubjectPopopViewDisplayed = NO;
    
    [self showMyPositionView:NO animated:NO];
    [self showMaterialView:NO animated:NO];

    self.topLineView.backgroundColor            = [[BBConfig sharedConfig] customColor];
    self.myPositionPopDownView.backgroundColor  = [[BBConfig sharedConfig] customColor];
    self.materialPopDownView.backgroundColor    = [[BBConfig sharedConfig] customColor];
    
    self.navBarTitleLabel.font          = [[BBConfig sharedConfig] lightFontWithSize:16];
    self.myPositionPopDownLabel.font    = [[BBConfig sharedConfig] lightFontWithSize:14];
    self.materialPopDownLabel.font      = [[BBConfig sharedConfig] lightFontWithSize:12];
    self.materialTopSubtitleLabel.font  = [[BBConfig sharedConfig] lightFontWithSize:10];
    
    self.materialTopTitleLabel.font     = [[BBConfig sharedConfig] regularFontWithSize:12];

    [self.navBarTitleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.myPositionPopDownLabel setAdjustsFontSizeToFitWidth:YES];
    [self.materialPopDownLabel setAdjustsFontSizeToFitWidth:YES];
    [self.materialPopDownText setAdjustsFontSizeToFitWidth:YES];

    self.navBarTitleLabel.text = @"";
    self.navBarTitleLabel.textColor = [UIColor colorWithRed:97.0f/255.0f green:97.0f/255.0f blue:97.0f/255.0f alpha:1.0];
    
    self.myPositionPopDownLabel.text = @"";
    self.myPositionPopDownLabel.textColor = [UIColor whiteColor];
    
    self.materialPopDownLabel.text = @"";
    self.materialPopDownLabel.textColor = [UIColor whiteColor];
    
    self.materialPopDownText.text = @"";
    self.materialPopDownText.textColor = [UIColor whiteColor];

    [self.myPositionPopDownButton setTitle:NSLocalizedStringFromTable(@"show.my.position", @"BBLocalizable", nil).uppercaseString forState:UIControlStateNormal];
    [self.materialPopDownButton setTitle:NSLocalizedStringFromTable(@"show.material", @"BBLocalizable", nil).uppercaseString forState:UIControlStateNormal];
    
    [self applyRoundAndShadow:self.myLocationButton];
    [self applyRoundAndShadow:self.pointsOfInterestButton];
    
    myCurrentLocationView = [[BBMyPositionView alloc] initWithFrame:CGRectMake(0, 0, BB_MY_POSITION_WIDTH, BB_MY_POSITION_WIDTH)];
    myCurrentLocationView.tag = BB_MAP_TAG_MY_POSITION;
    myCurrentLocationView.hidden = YES;
    
    [self.myLocationButton setImage:[UIImage imageNamed:@"location-icon"] forState:UIControlStateNormal];
    [self.pointsOfInterestButton setImage:[UIImage imageNamed:@"marker-icon"] forState:UIControlStateNormal];
    
    [self.mapScrollView addSubview:myCurrentLocationView];
    
    self.mapScrollView.bounces = YES;
    self.mapScrollView.alwaysBounceVertical = YES;
    self.mapScrollView.alwaysBounceHorizontal = YES;

    [self updateMapScrollViewContentInsets];
    
    pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
 
    self.navBarNextButton.enabled = NO;
    self.navBarPreviousButton.enabled = NO;

    if (self.foundSubject != nil) {
        self.materialTopTitleLabel.text = self.foundSubject.subject_name.uppercaseString;
        self.materialTopSubtitleLabel.text = self.foundSubject.subject_subtitle.uppercaseString;
        self.materialTopImageView.image = [self.foundSubject.subject_image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.materialTopImageView.tintColor = [UIColor colorWithRed:97.0f/255.0f green:97.0f/255.0f blue:97.0f/255.0f alpha:1.0];

        self.materialTopBar.hidden = false;
        
    } else {
        self.materialTopBar.hidden = true;
    }
    
    [self.spinner startAnimating];
    [[BBDataManager sharedInstance] requestCurrentPlaceSetupWithCompletion:^(BBPlace *result, NSError *error) {
        if (error == nil) {
            place = result;
            
            if (place == nil) {
                return;
            }
            
            if (place.floors != nil && place.floors.count > 0) {

                currentDisplayFloorRef = place.floors.firstObject;

                if (self.foundSubject != nil) {
                    for (BBFloor *floor in place.floors) {
                        if (floor.floor_id == self.foundSubject.floor_id) {
                            currentDisplayFloorRef = floor;
                            break;
                        }
                    }
                }
                
                [currentDisplayFloorRef clearAllAccuracyDataPoints];
                myCoordinate = CGPointZero;
                [self layoutCurrentFloorplan];
                [self layoutMyLocationAnimated:false];
                [self startLookingForBeacons];
                
            } else {
                NSLog(@"No floors available for this configuration");
                [self.spinner stopAnimating];
            }
            
        } else {
            [self.spinner stopAnimating];
            self.navBarTitleLabel.text = NSLocalizedStringFromTable(@"unsupported.place.title", @"BBLocalizable", nil).uppercaseString;
            [self showAlert:NSLocalizedStringFromTable(@"unsupported.place.title", @"BBLocalizable", nil) message:NSLocalizedStringFromTable(@"unsupported.place.message", @"BBLocalizable", nil)];
        }
        
    }];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self != nil) {
        [self layoutPOI];
    }
    if (currentDisplayFloorRef != nil) {
        [self startLookingForBeacons];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.locationManager stopMonitoringForRegion:[self beaconRegion]];
    [self.locationManager stopRangingBeaconsInRegion:[self beaconRegion]];
    _bluetoothManager = nil;
}

- (void) startLookingForBeacons {
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied){
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.locationManager.delegate = self;
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        
        [self.locationManager startMonitoringForRegion:[self beaconRegion]];
        [self.locationManager startRangingBeaconsInRegion:[self beaconRegion]];
        
        _bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:CBCentralManagerOptionShowPowerAlertKey]];
        
    } else {
        [self showAlert:NSLocalizedStringFromTable(@"invalid.current.location.title", @"BBLocalizable", nil) message:NSLocalizedStringFromTable(@"invalid.current.location.message", @"BBLocalizable", nil)];
    }

}

- (CLBeaconRegion*) beaconRegion {
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"f7826da6-4fa2-4e98-8024-bc5b71e0893e"];
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"identifier"];
    return beaconRegion;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // This delegate method will monitor for any changes in bluetooth state and respond accordingly
    NSString *stateString = nil;
    switch(_bluetoothManager.state) {
        case CBCentralManagerStateResetting: stateString = @"The connection with the system service was momentarily lost, update imminent.";
            myCurrentLocationView.hidden = YES;
            break;
        case CBCentralManagerStateUnsupported: stateString = @"The platform doesn't support Bluetooth Low Energy.";
            myCurrentLocationView.hidden = YES;
            break;
        case CBCentralManagerStateUnauthorized: stateString = @"The app is not authorized to use Bluetooth Low Energy.";
            myCurrentLocationView.hidden = YES;
            break;
        case CBCentralManagerStatePoweredOff: stateString = @"Bluetooth is currently powered off.";
            [self showAlert:NSLocalizedStringFromTable(@"invalid.current.location.title", @"BBLocalizable", nil) message:NSLocalizedStringFromTable(@"invalid.current.location.message", @"BBLocalizable", nil)];
            break;
        default: stateString = @"State unknown, update imminent.";
            myCurrentLocationView.hidden = YES;
            break;
    }
    NSLog(@"Bluetooth State: %@",stateString);

}

- (void)showAlert:(NSString*)title message:(NSString*)message {
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"ok", @"BBLocalizable", nil).uppercaseString otherButtonTitles:nil] show];
}

#pragma mark - UI Helpers

- (void) updateNavBarNextPrevButtons {
    if (currentDisplayFloorRef == nil) {
        return;
    }
    
    if (place.floors.count <= 1) {
        self.navBarNextButton.enabled = NO;
        self.navBarPreviousButton.enabled = NO;
    } else {
        NSInteger idx = [place.floors indexOfObject:currentDisplayFloorRef];
        
        self.navBarPreviousButton.enabled = idx >= 1;
        self.navBarNextButton.enabled = idx != place.floors.count-1;
    }

}

- (void) layoutCurrentFloorplan {
    
    __weak __typeof__(self) weakSelf = self;

    [currentDisplayFloorRef getFloorplanImage:^(UIImage *image, NSError *error) {
        if (error == nil) {
            if (image == nil) {
                NSLog(@"An error occured: %@", @"No Image");
                [weakSelf.spinner stopAnimating];
            } else {
                if (floorplanImageView == nil) {
                    floorplanImageView = [[UIImageView alloc] initWithImage:image];
                    floorplanImageView.tag = BB_MAP_TAG_FLOORPLAN;
                }
                self.mapScrollView.backgroundColor = [self colorAtImage:image xCoordinate:0 yCoordinate:0];
                floorplanImageView.image = image;
                scaleRatio = [self minScale];
                floorplanImageView.frame = CGRectMake(0, 0, image.size.width * scaleRatio, image.size.height * scaleRatio);

                // Default Scale Ratio
                [weakSelf.mapScrollView setContentSize: floorplanImageView.frame.size];
                
                CGPoint center = floorplanImageView.center;
                CGRect frame = weakSelf.mapScrollView.frame;
                
                [weakSelf.mapScrollView setContentOffset:CGPointMake(center.x - frame.size.width/2, center.y - frame.size.height/2)];
                
                [weakSelf.mapScrollView addSubview:floorplanImageView];
                [weakSelf.spinner stopAnimating];
                
                [self layoutPOI];
            }
        } else {
            NSLog(@"An error occured: %@",error.localizedDescription);
            [weakSelf.spinner stopAnimating];
        }
    }];
    
    if (currentDisplayFloorRef == nil) {
        self.navBarTitleLabel.text = @"";
        self.navBarNextButton.enabled = NO;
        self.navBarPreviousButton.enabled = NO;
        return;
    }
    
    self.navBarTitleLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedStringFromTable(@"showing", @"BBLocalizable", nil).uppercaseString, currentDisplayFloorRef.name.uppercaseString];
    [self updateNavBarNextPrevButtons];
}

- (void) layoutPOI {
    
        for (UIView *view in self.mapScrollView.subviews) {
            if (view.tag == BB_MAP_TAG_MY_POSITION || view.tag == BB_MAP_TAG_FLOORPLAN) {
                continue;
            } else {
                [view removeFromSuperview];
            }
        }

        if (place == nil) {
            return;
        }
        
        if (self.foundSubject != nil) {
            
            if (self.foundSubject.floor_id == currentDisplayFloorRef.floor_id) {
                
                [self showMaterialView:NO animated:YES];
                
                BBPOIMapView *foundMaterialPOIView = [[BBPOIMapView alloc] initWithFrame:CGRectMake(self.foundSubject.location_posX * scaleRatio - BB_POI_WIDTH/2, self.foundSubject.location_posY * scaleRatio - BB_POI_WIDTH/2, BB_POI_WIDTH, BB_POI_WIDTH)];
                
                foundMaterialPOIView.poiIconView.image = [self.foundSubject.subject_image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                foundMaterialPOIView.poiIconView.tintColor = [UIColor whiteColor];
                [self.mapScrollView addSubview:foundMaterialPOIView];
                
                if (!foundSubjectPopopViewDisplayed) {
                    popupView = [[[NSBundle mainBundle] loadNibNamed:@"BBPopupView" owner:self options:nil] firstObject];
                    [popupView setFrame:CGRectMake(self.foundSubject.location_posX * scaleRatio - BB_POPUP_WIDTH / 2, self.foundSubject.location_posY * scaleRatio - BB_POPUP_HEIGHT, BB_POPUP_WIDTH, BB_POPUP_HEIGHT)];
                    popupView.labelTitle.text = NSLocalizedStringFromTable(@"here.is.your.material", @"BBLocalizable", nil).uppercaseString;
                    popupView.labelText.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"your.material.is.at.x", @"BBLocalizable", nil), currentDisplayFloorRef.name];
                    [popupView.buttonOK setTitle:NSLocalizedStringFromTable(@"ok.find.me", @"BBLocalizable", nil).uppercaseString forState:UIControlStateNormal];
                    [popupView.buttonOK addTarget:self action:@selector(popupViewOkButtonAction:) forControlEvents: UIControlEventTouchUpInside];
                    [self.mapScrollView addSubview:popupView];
                }
                
            } else {
                [self showMaterialView:YES animated:YES];
            }
        }
        
//        // DEBUG !!!!!!
//        for (BBBeaconLocation *beaconLocation in currentDisplayFloorRef.beaconLocations) {
//            
//            CGFloat beaconWidth = 12.f;
//            CGPoint position = [beaconLocation coordinate];
//            UIView *poiView = [[UIView alloc] initWithFrame:(CGRectMake(position.x * scaleRatio - beaconWidth/2, position.y * scaleRatio - beaconWidth/2, beaconWidth, beaconWidth))];
//            poiView.backgroundColor = [UIColor whiteColor];
//            
//            poiView.layer.cornerRadius = beaconWidth/2;
//            poiView.layer.masksToBounds = YES;
//            poiView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
//            poiView.layer.borderWidth = 2.f;
//            [self.mapScrollView addSubview:poiView];
//        }
//        // DEBUG END !!!
        
        [[BBDataManager sharedInstance] requestSelectedPOIMenuItemsWithCompletion:^(NSArray *result, NSError *error) {
            
            if (result == nil || result.count == 0) {
                return;
            }
            NSMutableDictionary *displayPOI = [NSMutableDictionary new];
            
            for (BBPOIMenuItem *menuItem in result) {
                if ([menuItem isPOIMenuItem] == YES) {
                    if (menuItem.poi.selected == YES) {
                        [displayPOI setObject:menuItem.poi forKey:[NSString stringWithFormat:@"%ld",(long)menuItem.poi.poi_id]];
                        
                    }
                }
            }
            for (BBPOILocation *poiLocation in currentDisplayFloorRef.poiLocations) {
                BBPOI *poi = [displayPOI objectForKey:[NSString stringWithFormat:@"%ld",(long)poiLocation.poi.poi_id]];
                if (poi != nil) {
                    
                    if ([poi.type isEqualToString:BB_POI_TYPE_AREA]) {
                        
                        // Layout All Areas's (at the bottom)
                        CGMutablePathRef p = CGPathCreateMutable() ;
                        CGPoint startingPoint = [poiLocation.area.firstObject CGPointValue];
                        
                        CGFloat minX = startingPoint.x;
                        CGFloat maxX = startingPoint.x;
                        
                        CGFloat minY = startingPoint.y;
                        CGFloat maxY = startingPoint.y;
                        
                        for (NSValue *pointValue in poiLocation.area) {
                            CGPoint point = [pointValue CGPointValue];
                            
                            minX = fmin(point.x, minX);
                            maxX = fmax(point.x, maxX);
                            
                            minY = fmin(point.y, minY);
                            maxY = fmax(point.y, maxY);
                        }

                        CGSize size = CGSizeMake(fabs(minX - maxX), fabs(minY - maxY));

                        
                        for (NSValue *pointValue in poiLocation.area) {
                            CGPoint point = [pointValue CGPointValue];
                            
                            if (pointValue == poiLocation.area.firstObject) {
                                CGPathMoveToPoint(p, NULL, floor((point.x - minX) * scaleRatio), floor((point.y - minY) * scaleRatio));
                            } else {
                                CGPathAddLineToPoint(p, NULL, floor((point.x - minX) * scaleRatio), floor((point.y - minY) * scaleRatio));
                            }
                        }

                        CGPathCloseSubpath(p) ;
                        
                        CAShapeLayer *layer = [CAShapeLayer layer];
                        layer.path = p;
                        layer.fillColor = [[UIColor colorFromHexString:poiLocation.poi.hex_color] colorWithAlphaComponent:0.4].CGColor;
                        
                        
                        BBPOIAreaMapView *areaView = [[BBPOIAreaMapView alloc] initWithFrame:CGRectMake(minX * scaleRatio, minY * scaleRatio, size.width * scaleRatio, size.height * scaleRatio)];
                        
                        areaView.areaTitleVisible = false;
                        areaView.areaTitle = poi.name;
                        areaView.clipsToBounds = NO;
                        [areaView.layer addSublayer:layer];
                        [self.mapScrollView insertSubview:areaView atIndex:2];
                        
                    } else
                        if ([poi.type isEqualToString:BB_POI_TYPE_ICON]) {
                            // Layout All POI (at the middle)
                            CGPoint position = [poiLocation coordinate];
                            BBPOIMapView *poiView = [[BBPOIMapView alloc] initWithFrame:CGRectMake(position.x * scaleRatio - BB_POI_WIDTH/2, position.y * scaleRatio - BB_POI_WIDTH/2, BB_POI_WIDTH, BB_POI_WIDTH)];
                            
                            __weak UIImageView* weakPOIIconView = poiView.poiIconView;
                            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:poiLocation.poi.icon_url]];
                            [poiView.poiIconView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                weakPOIIconView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                                weakPOIIconView.tintColor = [UIColor whiteColor];
                            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                NSLog(@"An error occured: %@",error.localizedDescription);
                            }];
                            [self.mapScrollView addSubview:poiView];
                        }
                }
            }
            // Bring My Current Location at the top
            [myCurrentLocationView.superview bringSubviewToFront:myCurrentLocationView];
        }];
}

- (void) layoutMyLocationAnimated:(Boolean) animated {
    
    CGFloat animationDuration = animated ? myCurrentLocationView.hidden ? 0 : 10 : 0;
    if (!CGPointEqualToPoint(myCoordinate, CGPointZero)) {
        if (myCoordinate.x > 0 && myCoordinate.x < floorplanImageView.image.size.width &&
            myCoordinate.y > 0 && myCoordinate.y < floorplanImageView.image.size.height) {
            [UIView animateWithDuration:animationDuration animations:^{
                
                if (![self isWalkablePixel:floorplanImageView.image xCoordinate:myCoordinate.x yCoordinate:myCoordinate.y]) {
                    [self zoomToMyPosition];
                    return;
                }
                myCurrentLocationView.frame = CGRectMake(myCoordinate.x * scaleRatio - myCurrentLocationView.frame.size.width/2, myCoordinate.y * scaleRatio - myCurrentLocationView.frame.size.height/2, myCurrentLocationView.frame.size.height, myCurrentLocationView.frame.size.width);
                [myCurrentLocationView.superview bringSubviewToFront:myCurrentLocationView];
                myCurrentLocationView.hidden = NO;
                [self zoomToMyPosition];
                [myCurrentLocationView addPulsatingAnimation];
                
            }];
        }
    } else {
        myCurrentLocationView.hidden = YES;
    }
}

- (void) zoomToMyPosition {
    if (zoomToUserPosition) {
        CGRect position = [[myCurrentLocationView.layer presentationLayer] frame];
        
        CGPoint center = CGPointMake(position.origin.x + position.size.width/2, position.origin.y + position.size.height/2);
        
        [self.mapScrollView setContentOffset:CGPointMake(center.x - roundf(self.mapScrollView.frame.size.width/2.),center.y - roundf(self.mapScrollView.frame.size.height/2)) animated:YES];
        
        zoomToUserPosition = NO;
    }
}

- (BOOL)isWalkablePixel:(UIImage *)image xCoordinate:(int)x yCoordinate:(int)y {
    
    UIColor *pixel_color = [self colorAtImage:image xCoordinate:x yCoordinate:y];
    UIColor *walkable_color = [UIColor colorFromHexString:currentDisplayFloorRef.map_walkable_color];
    return [self color:pixel_color isEqualToColor:walkable_color withTolerance:0.05];
}


- (UIColor *) colorAtImage:(UIImage *)image xCoordinate:(int)x yCoordinate:(int)y {
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    int pixelInfo = ((image.size.width  * y) + x ) * 4;
    
    UInt8 red = data[pixelInfo];
    UInt8 green = data[(pixelInfo + 1)];
    UInt8 blue = data[pixelInfo + 2];
    UInt8 alpha = data[pixelInfo + 3];
    CFRelease(pixelData);
    
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f];
}

- (BOOL)color:(UIColor *)color1 isEqualToColor:(UIColor *)color2 withTolerance:(CGFloat)tolerance {
    
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    [color1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    return
    fabs(r1 - r2) <= tolerance &&
    fabs(g1 - g2) <= tolerance &&
    fabs(b1 - b2) <= tolerance &&
    fabs(a1 - a2) <= tolerance;
}

- (BBFloor *) floorForFloorID:(NSInteger) floorId {

    if (place == nil || place.floors == nil) {
        return nil;
    }
    
    for (BBFloor *floor in place.floors) {
        if (floor.floor_id == floorId) {
            return floor;
        }
    }
    
    return nil;
}

#pragma mark - Pop Down

- (void) showMyPositionView:(BOOL)shouldShow animated:(BOOL)animated {
    CGFloat animationDuration = animated ? 0.35 : 0;
    showMyPositionView = shouldShow;
    
    self.myPositionPopDownLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedStringFromTable(@"you.are.here", @"BBLocalizable", nil), rangedBeconsFloorRef.name].uppercaseString;
    
    if (shouldShow) {
        self.myPositionPopDownTopConstraint.constant = 0;
    } else {
        self.myPositionPopDownTopConstraint.constant = -self.myPositionPopDownView.frame.size.height;
    }
    
    [self updateMapScrollViewContentInsets];
    
    [self.view needsUpdateConstraints];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void) showMaterialView:(BOOL)shouldShow animated:(BOOL)animated {
    CGFloat animationDuration = animated ? 0.35 : 0;
    showMaterialView = shouldShow;
    
    BBFloor *materialFloor = [self floorForFloorID:self.foundSubject.floor_id];
    if (materialFloor == nil) {
        // Don't show when floor isn't found.
        shouldShow = NO;
    }
    
    if (rangedBeconsFloorRef == nil || rangedBeconsFloorRef.name == nil) {
        self.materialPopDownLabel.text = nil;
    } else {
        self.materialPopDownLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedStringFromTable(@"you.are.at", @"BBLocalizable", nil), rangedBeconsFloorRef.name].uppercaseString;
    }
    self.materialPopDownText.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedStringFromTable(@"your.material.is.at", @"BBLocalizable", nil), materialFloor.name].uppercaseString;
    
    if (shouldShow) {
        self.materialPopDownTopConstraint.constant = 0;
    } else {
        self.materialPopDownTopConstraint.constant = -self.materialPopDownView.frame.size.height;
    }
    
    [self updateMapScrollViewContentInsets];
    
    [self.view needsUpdateConstraints];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void) updateMapScrollViewContentInsets {
    
    if (showMaterialView) {
        self.mapScrollView.contentInset = UIEdgeInsetsMake(BB_POPUP_HEIGHT + self.materialPopDownView.frame.size.height, BB_POPUP_WIDTH/2, BB_POPUP_HEIGHT, BB_POPUP_WIDTH/2);
    } else if (showMyPositionView) {
        self.mapScrollView.contentInset = UIEdgeInsetsMake(BB_POPUP_HEIGHT + self.myPositionPopDownView.frame.size.height, BB_POPUP_WIDTH/2, BB_POPUP_HEIGHT, BB_POPUP_WIDTH/2);
    } else {
        self.mapScrollView.contentInset = UIEdgeInsetsMake(BB_POPUP_HEIGHT, BB_POPUP_WIDTH/2, BB_POPUP_HEIGHT, BB_POPUP_WIDTH/2);
    }
}

#pragma mark - Pinch Gesture

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)sender {
    
    if (floorplanImageView == nil) {
        return;
    }
    
    myCurrentLocationView.hidden = YES;

    double maxScale = 1.0;
    double minScale = [self minScale];
    
    double newScaleRatio = scaleRatio * (1.0 - ((1.0 - sender.scale) / 10));
    scaleRatio = newScaleRatio >= maxScale ? maxScale : newScaleRatio <= minScale ? minScale : newScaleRatio;

    floorplanImageView.frame = CGRectMake(0, 0, floorplanImageView.image.size.width * scaleRatio, floorplanImageView.image.size.height * scaleRatio);
    self.mapScrollView.contentSize = floorplanImageView.bounds.size;
    
    [self layoutPOI];
    [self layoutMyLocationAnimated:YES];
}

- (double) minScale {
    double minScaleWidth = self.mapScrollView.bounds.size.width / floorplanImageView.image.size.width;
    double minScaleHeight = self.mapScrollView.bounds.size.height / floorplanImageView.image.size.height;
    
    return fmax(minScaleHeight, minScaleWidth);
}

#pragma mark - Actions

- (IBAction)closeButtonAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)navBarNextAction:(id)sender {
    if (currentDisplayFloorRef == nil) {
        return;
    }
 
    NSInteger idx = [place.floors indexOfObject:currentDisplayFloorRef];
    currentDisplayFloorRef = place.floors[idx + 1];
    [currentDisplayFloorRef clearAllAccuracyDataPoints];
    myCoordinate = CGPointZero;
    [self layoutCurrentFloorplan];
    [self layoutMyLocationAnimated:NO];
}

- (IBAction)navBarPreviousAction:(id)sender {
    if (currentDisplayFloorRef == nil) {
        return;
    }
    
    NSInteger idx = [place.floors indexOfObject:currentDisplayFloorRef];
    currentDisplayFloorRef = place.floors[idx - 1];
    [currentDisplayFloorRef clearAllAccuracyDataPoints];
    myCoordinate = CGPointZero;
    [self layoutCurrentFloorplan];
    [self layoutMyLocationAnimated:NO];
}

- (IBAction)pointsOfInterestAction:(id)sender {
    currentPOIViewController = nil;
    currentPOIViewController = [[BBLibraryMapPOIViewController alloc] initWithNibName:@"BBLibraryMapPOIViewController" bundle:nil];
    [self presentViewController:currentPOIViewController animated:true completion:nil];
}

- (IBAction)myLocationAction:(id)sender {
    if (rangedBeconsFloorRef != nil) {
        if (currentDisplayFloorRef.floor_id != rangedBeconsFloorRef.floor_id) {
            currentDisplayFloorRef = rangedBeconsFloorRef;
            [currentDisplayFloorRef clearAllAccuracyDataPoints];
            [self layoutCurrentFloorplan];
            zoomToUserPosition = YES;
            [self layoutMyLocationAnimated:NO];
        } else {
            zoomToUserPosition = YES;
            [self layoutMyLocationAnimated:NO];
            
        }
    }
}

- (IBAction)popupViewOkButtonAction:(id)sender {
    foundSubjectPopopViewDisplayed = YES;
    [popupView removeFromSuperview];
    popupView = nil;
    [self myLocationAction:nil];
}

- (IBAction)myPositionPopDownButtonAction:(id)sender {
    [self myLocationAction:nil];
}

- (IBAction)materialPopDownButtonAction:(id)sender {
    foundSubjectPopopViewDisplayed = NO;
    if (currentDisplayFloorRef.floor_id != self.foundSubject.floor_id) {
        if (self.foundSubject != nil) {
            for (BBFloor *floor in place.floors) {
                if (floor.floor_id == self.foundSubject.floor_id) {
                    currentDisplayFloorRef = floor;
                    break;
                }
            }
        }
        myCoordinate = CGPointZero;
        [currentDisplayFloorRef clearAllAccuracyDataPoints];
        [self layoutCurrentFloorplan];
        zoomToUserPosition = YES;
        [self layoutMyLocationAnimated:NO];
    } else {
        zoomToUserPosition = YES;
        [self layoutMyLocationAnimated:NO];
        
    }
   
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)rangeBeacons inRegion:(CLBeaconRegion *)region {
    
    if (place == nil) {
        myCoordinate = CGPointZero;
        [self layoutMyLocationAnimated:false];
        return;
    }
    
    NSMutableArray *rangedFloors = [NSMutableArray new];
    for (CLBeacon *beacon in rangeBeacons) {
        BBFloor *floor = [place matchingBBFloor:beacon];
        if (floor == nil) { continue; }
        
        [rangedFloors addObject:floor];
        if (rangedFloors.count == 3) {
            break;
        }
    }
    
    if (rangedFloors.count < 3) {
        rangedBeconsFloorRef = nil;
    } else if (((BBFloor *)rangedFloors[0]).floor_id == ((BBFloor *)rangedFloors[1]).floor_id == ((BBFloor *)rangedFloors[2]).floor_id) {
        rangedBeconsFloorRef = rangedFloors[0];
    } else if (((BBFloor *)rangedFloors[0]).floor_id == ((BBFloor *)rangedFloors[1]).floor_id || ((BBFloor *)rangedFloors[0]).floor_id == ((BBFloor *)rangedFloors[2]).floor_id) {
        rangedBeconsFloorRef = rangedFloors[0];
    } else if (((BBFloor *)rangedFloors[1]).floor_id == ((BBFloor *)rangedFloors[0]).floor_id || ((BBFloor *)rangedFloors[1]).floor_id == ((BBFloor *)rangedFloors[2]).floor_id) {
        rangedBeconsFloorRef = rangedFloors[1];
    } else {
        rangedBeconsFloorRef = nil;
    }
    
    if (rangedBeconsFloorRef == nil) {
        [self showMyPositionView:NO animated:NO];
    } else {
        
        if (self.foundSubject == nil) {
            [self showMyPositionView:(currentDisplayFloorRef.floor_id != rangedBeconsFloorRef.floor_id) animated:YES];
        } else {
            [self showMyPositionView:NO animated:NO];
        }

    }
    
    NSMutableArray *rangedBBBeacons = [NSMutableArray new];
    for (CLBeacon *beacon in rangeBeacons) {
        BBBeaconLocation *beaconLocation = [currentDisplayFloorRef matchingBBBeacon:beacon];
        if (beaconLocation.beacon == nil) {
            continue;
        }
        if (beacon.accuracy > 0) {
            [beaconLocation.beacon.accuracyDataPoints addObject:@(beacon.accuracy)];
            if (beaconLocation.beacon.accuracyDataPoints.count > 5) {
                [beaconLocation.beacon.accuracyDataPoints removeObjectAtIndex:0];
            }
        }

        [rangedBBBeacons addObject:beaconLocation];
        if (rangedBBBeacons.count == 3) {
            break;
        }
    }
    
    if (rangedBBBeacons.count >= 3) {
        BBBeaconLocation *beaconA = rangedBBBeacons[0];
        BBBeaconLocation *beaconB = rangedBBBeacons[1];
        BBBeaconLocation *beaconC = rangedBBBeacons[2];
        
        // Try Some Trilateration
        BBTrilateration *trilateration = [[BBTrilateration alloc] init];
        
        trilateration.beaconA = [beaconA coordinate];
        trilateration.beaconB = [beaconB coordinate];
        trilateration.beaconC = [beaconC coordinate];
        
        trilateration.distA = [[trilateration optimizeDistanceAverage:beaconA.beacon.accuracyDataPoints] doubleValue] * 100 * currentDisplayFloorRef.map_pixel_to_centimeter_ratio; // Accuracy is in Meters - Convert to pixels!
        trilateration.distB = [[trilateration optimizeDistanceAverage:beaconB.beacon.accuracyDataPoints] doubleValue] * 100 * currentDisplayFloorRef.map_pixel_to_centimeter_ratio; // Accuracy is in Meters - Convert to pixels!
        trilateration.distC = [[trilateration optimizeDistanceAverage:beaconC.beacon.accuracyDataPoints] doubleValue] * 100 * currentDisplayFloorRef.map_pixel_to_centimeter_ratio; // Accuracy is in Meters - Convert to pixels!
        
        myCoordinate = [trilateration getMyCoordinate];
//        NSLog(@"%@", trilateration.description);
        [self layoutMyLocationAnimated:true];
    }
    
    
}


@end