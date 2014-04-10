//
//  AppDelegate.m
//  ZomBeacon
//
//  Created by Patrick Adams on 12/11/13.
//  Copyright (c) 2013 Patrick Adams. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Parse framework account setup
    [Parse setApplicationId:@"PnxqTJvBhgcyJaz3PAjo1k9I9XdmxLLya8t9QGjI"
                  clientKey:@"oBSGVpLdkahu5oHsSzQUZIKlYBrqgKGktDU8mzrI"];
    
    //Parse analytics
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    //Initializes the Facebook SDK
    [PFFacebookUtils initializeFacebook];
    
    //Lets me use the PFImageView class in place of a UIImageView
    [PFImageView class];
    
    //Initializes the Twitter SDK
    [PFTwitterUtils initializeWithConsumerKey:@"4Oj2HtCnI9e8ALYhApmEyg"
                               consumerSecret:@"q0wXLhwm6qSdEiM1BmnPEcfYYJ36HbASJ62WENgEBo"];
    
    //Bluetooth Central Manager
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRangingForSurvivors) name:@"isZombie" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRangingForZombies) name:@"isSurvivor" object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLocation) name:@"getLocation" object: nil];
    
    if ([CLLocationManager isRangingAvailable] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device Not Supported" message:@"Only iPhone 4s and up will work with this app." delegate:nil cancelButtonTitle:@"Not cool!" otherButtonTitles:nil];
        
        [alert show];
    }
    
    presentedView = NO;
    
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    return YES;
}

- (void)reachabilityChanged:(NSNotification*)notification
{
	Reachability* reachability = notification.object;
    
    UINavigationController *navCon = (UINavigationController*)self.window.rootViewController;
    
	if(reachability.currentReachabilityStatus == NotReachable)
    {
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NetworkViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"network"];
        [navCon presentViewController:vc animated:NO completion:nil];
        presentedView= YES;
    }
	else if(reachability.currentReachabilityStatus != NotReachable && presentedView == YES)
    {
		[navCon dismissViewControllerAnimated:NO completion:nil];
        presentedView = NO;
    }
}

- (void)openGameDetailsView:(NSString *)forGame
{
    PFQuery *query = [PFQuery queryWithClassName:@"PrivateGames"];
    [query whereKey:@"objectId" equalTo:forGame];
    [query includeKey:@"hostUser"];
    PFObject *privateGame = [query getFirstObject];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GameDetailsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"gamedetails"];
    UINavigationController *navCon = (UINavigationController*)self.window.rootViewController;
    
    vc.gameDateString = privateGame[@"dateTime"];
    vc.gameNameString = privateGame[@"gameName"];
    PFGeoPoint *gameLocation = privateGame[@"location"];
    CLLocationCoordinate2D gameLocationCoords = CLLocationCoordinate2DMake(gameLocation.latitude, gameLocation.longitude);
    vc.gameLocationCoord = gameLocationCoords;
    vc.gameIdString = privateGame.objectId;
    
    PFObject *hostUser = privateGame[@"hostUser"];
    vc.gameHostString = hostUser[@"name"];
    
    [navCon pushViewController:vc animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self openGameDetailsView:self.gameIdString];
    }
}

- (void)getLocation
{
    if (![CLLocationManager locationServicesEnabled])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. ZomBeacon relies on location services to give you the best experience possible. Please enable them!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    else
    {
        //Starts location manager to track user location in the background
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 2.0f;
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [[PFUser currentUser] setObject:[NSNull null] forKey:@"location"];
    [[PFUser currentUser] saveInBackground];
}

- (void)startRangingForSurvivors
{
    //Start the beacon region monitoring when the controller loads
    BeaconManager *beaconManager = [BeaconManager sharedManager];
    beaconManager.delegate = self;
    [beaconManager startBeaconMonitoring:@"6170CEEF-4D17-4741-8068-850A601E32F0"];
    
    //Timer to check if didRangeBeacons ever gets called
    self.didRangeBeaconsTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(showAlert) userInfo:nil repeats:NO];
}

- (void)startRangingForZombies
{
    //Start the beacon region monitoring when the controller loads
    BeaconManager *beaconManager = [BeaconManager sharedManager];
    beaconManager.delegate = self;
    [beaconManager startBeaconMonitoring:@"1DC4825D-7457-474D-BE7B-B4C9B2D1C763"];
    
    //Timer to check if didRangeBeacons ever gets called
    self.didRangeBeaconsTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(showAlert) userInfo:nil repeats:NO];
}

//This method is to check if didRangeBeacons ever gets called, this is a known bug in 7.1
- (void)showAlert
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth Error" message:@"Your bluetooth is not functioning properly. Please reset your device to fix the issue. Thank you!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    else
    {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"Bluetooth Error: Your bluetooth is not functioning properly. Please reset your device to fix the issue. Thank you!";
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)beaconManager:(BeaconManager *)beaconManager didRangeBeacons:(NSArray *)beacons
{
    [self.didRangeBeaconsTimer invalidate];
    
    CLBeacon *beacon = [beacons lastObject];
    
    if (beacon.proximity == CLProximityNear || beacon.proximity == CLProximityImmediate)
    {
        [beaconManager stopBeaconMonitoring];
        
        NSString *publicStatus = [PFUser currentUser][@"publicStatus"];
        if ([publicStatus isEqualToString:@"survivor"])
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            PublicZombieViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicZombie"];
            UINavigationController *navCon = (UINavigationController*)self.window.rootViewController;
            
            if ([navCon.topViewController isKindOfClass:[PrivateSurvivorViewController class]] || [navCon.topViewController isKindOfClass:[PrivateZombieViewController class]])
            {
                //Do nothing
            }
            else
            {
               [navCon pushViewController:vc animated:YES];
            }
            
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"minor" equalTo:beacon.minor];
            [userQuery whereKey:@"major" equalTo:beacon.major];
            PFUser *userThatInfected = (PFUser *)[userQuery getFirstObject];
            
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PUBLIC GAME" message:[NSString stringWithFormat:@"You've been bitten by user: %@. You are now a zombie!", userThatInfected.username] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
                
                //Set up push to send to person that bit you.
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"owner" equalTo:userThatInfected];
                
                PFPush *push = [PFPush new];
                [push setQuery:pushQuery];
                [push setData:@{ @"alert": [NSString stringWithFormat:@"BRAINSSS! You bit user %@ for +250 pts!", [PFUser currentUser].username] }];
                [push sendPushInBackground];
                
                //Adds 100 pts to the user's publicScore for a bite
                [self assignPointsFor:userThatInfected pointTotal:250.0f];
            }
            else
            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.alertBody = [NSString stringWithFormat:@"PUBLIC GAME: You've been bitten by user: %@. You are now a zombie!", userThatInfected.username];
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.applicationIconBadgeNumber = 1;
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                
                //Set up push to send to person that bit you.
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"owner" equalTo:userThatInfected];
                
                PFPush *push = [PFPush new];
                [push setQuery:pushQuery];
                [push setData:@{ @"alert": [NSString stringWithFormat:@"BRAINSSS! You bit user %@ for +250 pts!", [PFUser currentUser].username] }];
                [push sendPush:nil];
                
                //Adds 100 pts to the user's publicScore for a bite
                [self assignPointsFor:userThatInfected pointTotal:250.0f];
            }
            
            [[PFUser currentUser] setObject:@"zombie" forKey:@"publicStatus"];
            [[PFUser currentUser] saveInBackground];
        }
        else if ([publicStatus isEqualToString:@"zombie"])
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            PublicDeadViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicDead"];
            UINavigationController *navCon = (UINavigationController*)self.window.rootViewController;
            
            if ([navCon.topViewController isKindOfClass:[PrivateSurvivorViewController class]] || [navCon.topViewController isKindOfClass:[PrivateZombieViewController class]])
            {
                //Do nothing
            }
            else
            {
                [navCon presentViewController:vc animated:YES completion:nil];
                
                for (UIViewController *controller in [navCon viewControllers])
                {
                    if ([controller isKindOfClass:[MainMenuViewController class]])
                    {
                        [navCon popToViewController:controller animated:YES];
                        break;
                    }
                }
            }

            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"minor" equalTo:beacon.minor];
            [userQuery whereKey:@"major" equalTo:beacon.major];
            PFUser *userThatInfected = (PFUser *)[userQuery getFirstObject];
            
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PUBLIC GAME" message:[NSString stringWithFormat:@"You just got headshotted by %@. You are dead!", userThatInfected.username] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
                
                //Set up push to send to person that shot you.
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"owner" equalTo:userThatInfected];
                
                PFPush *push = [PFPush new];
                [push setQuery:pushQuery];
                [push setData:@{ @"alert": [NSString stringWithFormat:@"Nice! You headshotted user %@ for +500 pts!", [PFUser currentUser].username] }];
                [push sendPush:nil];
                
                //Adds 100 pts to the user's publicScore for a bite
                [self assignPointsFor:userThatInfected pointTotal:500.0f];
            }
            else
            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.alertBody = [NSString stringWithFormat:@"PUBLIC GAME: You just got headshotted by %@. You are dead!", userThatInfected.username];
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.applicationIconBadgeNumber = 1;
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                
                //Set up push to send to person that shot you.
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"owner" equalTo:userThatInfected];
                
                PFPush *push = [PFPush new];
                [push setQuery:pushQuery];
                [push setData:@{ @"alert": [NSString stringWithFormat:@"Nice! You headshotted user %@ for +500 pts!", [PFUser currentUser].username] }];
                [push sendPush:nil];
                
                //Adds 100 pts to the user's publicScore for a bite
                [self assignPointsFor:userThatInfected pointTotal:500.0f];
            }
            
            [[PFUser currentUser] setObject:@"dead" forKey:@"publicStatus"];
            [[PFUser currentUser] saveInBackground];
        }
    }
}

- (void)assignPointsFor:(PFUser *)userThatInfected pointTotal:(float)points
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserScore"];
    [query whereKey:@"user" equalTo:userThatInfected];
    PFObject *theUserScore = [query getFirstObject];
    float score = [theUserScore[@"publicScore"] floatValue];
    NSNumber *sum = [NSNumber numberWithFloat:score + points];
    [theUserScore setObject:sum forKey:@"publicScore"];
    [theUserScore saveInBackground];
}

#pragma mark - Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    
    // Create a pointer to the Photo object
    self.gameIdString = [userInfo objectForKey:@"code"];
    
    if (self.gameIdString != nil)
    {
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Private Game Invite" message:@"You've been invited to a private game of ZomBeacon." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"View Details", nil];
            
            [alert show];
        }
        else
        {
            [self openGameDetailsView:self.gameIdString];
        }
    }
    else
    {
        [PFPush handlePush:userInfo];
        NSLog(@"%@", userInfo);
    }
}

//#pragma mark - ProximityKit delegate methods
//
////Gets called when user enters any of the geo-fence locations
//- (void)proximityKit:(PKManager *)manager didEnter:(PKRegion *)region
//{
//    NSString *userStatus = [PFUser currentUser][@"publicStatus"];
//    
//    if ([userStatus isEqualToString:@"zombie"])
//    {
//        [[PFUser currentUser] setObject:@"survivor" forKey:@"publicStatus"];
//        [[PFUser currentUser] saveInBackground];
//        
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        PublicSurvivorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicSurvivor"];
//        UINavigationController *navCon = (UINavigationController*)self.window.rootViewController;
//        [navCon pushViewController:vc animated:NO];
//        
//        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PUBLIC GAME" message:@"You've entered a quarantine zone. You've been cured. You are now a Survivor." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            
//            [alert show];
//        }
//        else
//        {
//            UILocalNotification *notification = [[UILocalNotification alloc] init];
//            notification.alertBody = @"PUBLIC GAME: You've entered a quarantine zone. You've been cured. You are now a Survivor.";
//            notification.soundName = UILocalNotificationDefaultSoundName;
//            notification.applicationIconBadgeNumber = 1;
//            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
//        }
//    }
//}
//
////Gets called when user exits any of the geo-fence locations
//- (void)proximityKit:(PKManager *)manager didExit:(PKRegion *)region
//{
//    NSString *userStatus = [PFUser currentUser][@"publicStatus"];
//    
//    if ([userStatus isEqualToString:@"survivor"])
//    {
//        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PUBLIC GAME" message:@"You've left the quarantine zone. If you become infected come back to this spot to be cured." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            
//            [alert show];
//        }
//        else
//        {
//            UILocalNotification *notification = [[UILocalNotification alloc] init];
//            notification.alertBody = @"You've left the quarantine zone. If you become infected come back to this spot to be cured.";
//            notification.soundName = UILocalNotificationDefaultSoundName;
//            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
//        }
//    }
//}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //Shows blue tooth warning view controller if bluetooth is not enabled
    if (central.state == CBCentralManagerStatePoweredOff)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"bluetooth"];
        [self.window.rootViewController presentViewController:vc animated:NO completion:nil];
        
        [self.locationManager stopUpdatingLocation];
        [[PFUser currentUser] setObject:[NSNull null] forKey:@"location"];
        [[PFUser currentUser] saveInBackground];
    }
    
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - Custom URL Implementation

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *urlString = [url absoluteString];
    
    if ([urlString rangeOfString:@"com.facebook.sdk"].location != NSNotFound)
    {
        [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
    }
    if ([urlString rangeOfString:@"ZomBeacon://"].location != NSNotFound || [urlString rangeOfString:@"zombeacon://"].location != NSNotFound)
    {
        NSDictionary *dict = [self parseQueryString:[url query]];
        
        if (dict !=nil)
        {
            PFQuery *query = [PFQuery queryWithClassName:@"PrivateGames"];
            [query whereKey:@"objectId" equalTo:[dict valueForKey:@"invite"]];
            [query includeKey:@"hostUser"];
            NSArray *privateGames = [query findObjects];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            GameDetailsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"gamedetails"];
            
            if (privateGames.count > 0)
            {
                for (int i = 0; i < privateGames.count; i++)
                {
                    PFObject *privateGame = [privateGames objectAtIndex:0];
                    vc.gameDateString = privateGame[@"dateTime"];
                    vc.gameNameString = privateGame[@"gameName"];
                    PFGeoPoint *gameLocation = privateGame[@"location"];
                    CLLocationCoordinate2D gameLocationCoords = CLLocationCoordinate2DMake(gameLocation.latitude, gameLocation.longitude);
                    vc.gameLocationCoord = gameLocationCoords;
                    vc.gameIdString = privateGame.objectId;
                    
                    PFObject *hostUser = privateGame[@"hostUser"];
                    vc.gameHostString = hostUser[@"name"];
                }
                
                UINavigationController *navCon = (UINavigationController*)self.window.rootViewController;
                [navCon pushViewController:vc animated:NO];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Games Found" message:@"No games were found that match your code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
            }
        }

    }
    
    if ([urlString rangeOfString:@"http://zombeacon.com"].location != NSNotFound)
    {
        [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session] fallbackHandler:^(FBAppCall *call) {
            // Retrieve the exact url passed to your app during the cross-app call
            NSURL *originalURL = [[call appLinkData] originalURL];
            NSDictionary *dict = [self parseQueryString2:[NSString stringWithFormat:@"%@", originalURL]];
            
            if (dict !=nil)
            {
                PFQuery *query = [PFQuery queryWithClassName:@"PrivateGames"];
                [query whereKey:@"objectId" equalTo:[dict valueForKey:@"invite"]];
                [query includeKey:@"hostUser"];
                NSArray *privateGames = [query findObjects];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                GameDetailsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"gamedetails"];
                
                if (privateGames.count > 0)
                {
                    for (int i = 0; i < privateGames.count; i++)
                    {
                        PFObject *privateGame = [privateGames objectAtIndex:0];
                        vc.gameDateString = privateGame[@"dateTime"];
                        vc.gameNameString = privateGame[@"gameName"];
                        PFGeoPoint *gameLocation = privateGame[@"location"];
                        CLLocationCoordinate2D gameLocationCoords = CLLocationCoordinate2DMake(gameLocation.latitude, gameLocation.longitude);
                        vc.gameLocationCoord = gameLocationCoords;
                        vc.gameIdString = privateGame.objectId;
                        
                        PFObject *hostUser = privateGame[@"hostUser"];
                        vc.gameHostString = hostUser[@"name"];
                    }
                    
                    UINavigationController *navCon = (UINavigationController*)self.window.rootViewController;
                    [navCon pushViewController:vc animated:NO];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Games Found" message:@"No games were found that match your code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    
                    [alert show];
                }
            }
        }];
    }
    return YES;
}

- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

- (NSDictionary *)parseQueryString2:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"?"];
    
    for (NSString *pair in pairs)
    {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (types & UIRemoteNotificationTypeAlert)
    {
        //nothing
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Push Notifications Disabled" message:@"ZomBeacon uses push notifications to give you feedback during the game, please enable them to get the full experience." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

#pragma mark - Application State Methods

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
    [[PFUser currentUser] setObject:point forKey:@"location"];
    [[PFUser currentUser] saveInBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[PFUser currentUser] setObject:[NSNull null] forKey:@"location"];
    [[PFUser currentUser] save];
}

@end
