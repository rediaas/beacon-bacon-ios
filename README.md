# beacon-bacon-ios 

Demo app for https://github.com/nosuchagency/beacon-bacon

## GET STARTED

1. Request an API Key from https://beaconbacon.nosuchagency.com <br>(Read how to get setup Places / Points of Interest / Beacons etc. [here](https://github.com/nosuchagency/beacon-bacon))
2. BBConfig.h -> BB_API_KEY -> Insert your API Key
3. Import the lib into your project (Objective-C) [beacon-bacon-lib-ios](https://github.com/mustachedk/beacon-bacon-ios/tree/master/beaconbacon/beacon-bacon-lib-ios)
4. Import CoreLocation.framework into Linked Frameworks and Libraries

You are now able to use the lib. 
You can either use your own integration with API using element from the [./core](https://github.com/mustachedk/beacon-bacon-ios/tree/master/beaconbacon/beacon-bacon-lib-ios/core) folder.
You can also use the default UI library [./wayfinding](https://github.com/mustachedk/beacon-bacon-ios/tree/master/beaconbacon/beacon-bacon-lib-ios/wayfinding)

## USING WAYFINDING

You can see an example in [./ViewController.m](https://github.com/mustachedk/beacon-bacon-ios/blob/master/beaconbacon/ViewController.m)

####Start using a specific 'Place':
```Objective-C
[[BBConfig sharedConfig] setupWithPlaceIdentifier:@"YOUR_PLACE_ID" withCompletion:^(NSString *placeIdentifier, NSError *error) { 
   ...
}];
```

####Configure the UI:
```Objective-C
[BBConfig sharedConfig].customColor = [UIColor orangeColor];
[BBConfig sharedConfig].regularFont = [UIFont fontWithName:@"Avenir-Regular" size:16];
[BBConfig sharedConfig].lightFont   = [UIFont fontWithName:@"Avenir-Light" size:16];
```

####Initiate map without wayfinding:
```Objective-C
BBLibraryMapViewController *mapViewController = [[BBLibraryMapViewController alloc] initWithNibName:@"BBLibraryMapViewController" bundle:nil];
[self presentViewController:mapViewController animated:true completion:nil];
```

####Find IMS Subject
```Objective-C

BBIMSRequstSubject *requstObject = [[BBIMSRequstSubject alloc] initWithFaustId:@"FAUST_IDENTIFIER"];
[[BBDataManager sharedInstance] requestFindIMSSubject:requstObject withCompletion:^(BBFoundSubject *result, NSError *error) {
   if (error == nil) {
       if (result != nil) {
           // Subject is found for wayfinding
           result.subject_name     = @"NAME_TO_DISPLAY";
           result.subject_subtitle = @"SUBTITLE_TO_DISPLAY";
           result.subject_image    = [UIImage imageNamed:@"menu-library-map-icon"]; // Or any other icon you want it to display, eg. a book/video/tape etc.
           
           // 1. Store the BBFoundSubject 'result' for when you need to 'Initiate map with wayfinding'
           // 2. Optional: display/enable a button for wayfinding
       } else {
           ...
       }
   } else {
       if (error.code == BB_ERROR_CODE_SUBJECT_NOT_FOUND) {
           // No material found for way finding
           [[[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"ok", @"BBLocalizable", nil).uppercaseString otherButtonTitles:nil] show];
       } else {
           // Check for other error codes and handle error
       }   
   }
}];
```

####Initiate map with wayfinding:
```Objective-C
BBLibraryMapViewController *mapViewController = [[BBLibraryMapViewController alloc] initWithNibName:@"BBLibraryMapViewController" bundle:nil];
mapViewController.foundSubject = theFoundSubject; // Stored BBFoundSubject 'result' from BBDataManager.requestFindIMSSubject:

[self presentViewController:mapViewController animated:true completion:nil];
```
