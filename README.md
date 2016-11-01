# beacon-bacon-ios 

## GET STARTED

1. Setup your own BeaconBacon Server and get an API Key<br>(Read how to setup Places / Points of Interest / Beacons etc. [here](https://github.com/nosuchagency/beacon-bacon))
2. Import the beacon-bacon-ios lib into your project (Objective-C) [beacon-bacon-lib-ios](https://github.com/mustachedk/beacon-bacon-ios/tree/master/beacon-bacon-lib-ios)
3. Import CoreLocation.framework into Linked Frameworks and Libraries
4. Follow the instructions below to get started!

You are now able to use the lib. 
You can either use your own integration with API using element from the [./core](https://github.com/mustachedk/beacon-bacon-ios/tree/master/beacon-bacon-lib-ios/core) folder.
You can also use the default UI for wayfinding [./wayfinding](https://github.com/mustachedk/beacon-bacon-ios/tree/master/beacon-bacon-lib-ios/wayfinding)

## USING WAYFINDING

You can see an example in using the default wayfinding UI [Beacon Bacon IOS Demo](https://github.com/mustachedk/beacon-bacon-ios-demo)

####Configurate API and UI:
```Objective-C
// Configuration API Connection
[BBConfig sharedConfig].apiBaseURL  = @"INSERT_YOUR_API_BASE_URL";
[BBConfig sharedConfig].apiKey      = @"INSERT_YOUR_API_KEY";

// Configurate UI
[BBConfig sharedConfig].customColor = [UIColor orangeColor];
[BBConfig sharedConfig].regularFont = [UIFont fontWithName:@"Avenir-Regular" size:16];
[BBConfig sharedConfig].lightFont   = [UIFont fontWithName:@"Avenir-Light" size:16];
```

####Start using a specific 'Place':
```Objective-C
[[BBConfig sharedConfig] setupWithPlaceIdentifier:@"YOUR_PLACE_ID" withCompletion:^(NSString *placeIdentifier, NSError *error) { 
...
}];
```

####Initiate map without wayfinding:
```Objective-C
BBLibraryMapViewController *mapViewController = [[BBLibraryMapViewController alloc] initWithNibName:@"BBLibraryMapViewController" bundle:nil];
[self presentViewController:mapViewController animated:true completion:nil];
```

####Initiate Wayfinding with a IMS Request Object (it will automatically search when you select a new place)
```Objective-C

BBIMSRequstObject *requstObject = [[BBIMSRequstObject alloc] initWithFaustId:@"INSERT_FAUST_IDENTIFIER"];
requstObject.subject_name       = @"NAME_TO_DISPLAY";
requstObject.subject_subtitle   = @"SUBTITLE_TO_DISPLAY";
requstObject.subject_image      = [UIImage imageNamed:@"menu-library-map-icon"]; // Or any other icon you want it to display, eg. a book/video/tape etc.
    
mapViewController = [[BBLibraryMapViewController alloc] initWithNibName:@"BBLibraryMapViewController" bundle:nil];
mapViewController.wayfindingRequstObject = requstObject;
[self presentViewController:mapViewController animated:true completion:nil];
```


