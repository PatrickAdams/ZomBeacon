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
    
    //Proximity Kit
    self.proximityKitManager = [PKManager managerWithDelegate:self];
    [self.proximityKitManager start];
    
    return YES;
}

#pragma mark - Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

#pragma mark - ProximityKit delegate methods

//Gets called when user enters any of the geo-fence locations
- (void)proximityKit:(PKManager *)manager didEnter:(PKRegion *)region
{
    NSString *userStatus = [PFUser currentUser][@"publicStatus"];
    
    if ([userStatus isEqualToString:@"zombie"])
    {
        [[PFUser currentUser] setObject:@"survivor" forKey:@"publicStatus"];
        [[PFUser currentUser] saveInBackground];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PublicSurvivorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicSurvivor"];
        UINavigationController *navCon = (UINavigationController*)self.window.rootViewController;
        [navCon pushViewController:vc animated:NO];
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PUBLIC GAME" message:@"You've entered a quarantine zone. You've been cured. You are now a Survivor." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
        else
        {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.alertBody = @"PUBLIC GAME: You've entered a quarantine zone. You've been cured. You are now a Survivor.";
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.applicationIconBadgeNumber = 1;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
    }
}

//Gets called when user exits any of the geo-fence locations
- (void)proximityKit:(PKManager *)manager didExit:(PKRegion *)region
{
    NSString *userStatus = [PFUser currentUser][@"publicStatus"];
    
    if ([userStatus isEqualToString:@"survivor"])
    {
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PUBLIC GAME" message:@"You've left the quarantine zone. If you become infected come back to this spot to be cured." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
        else
        {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.alertBody = @"You've left the quarantine zone. If you become infected come back to this spot to be cured.";
            notification.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
    }
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //Shows blue tooth warning view controller if bluetooth is not enabled
    if (central.state == CBCentralManagerStatePoweredOff)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"bluetooth"];
        [self.window.rootViewController presentViewController:vc animated:NO completion:nil];
    }
    
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
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
    if ([urlString rangeOfString:@"zombeacon://"].location != NSNotFound)
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
}

#pragma mark - Application State Methods

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //Starts location manager to track user location in the background
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 1.3f;
    [self.locationManager startUpdatingLocation];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didEnterBackground" object:nil userInfo:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self saveLocation];
}

- (void)saveLocation
{
    if ([PFUser currentUser] != nil)
    {
        PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
        [[PFUser currentUser] setObject:point forKey:@"location"];
        [[PFUser currentUser] saveInBackground];
    }
    else
    {
        return;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self.locationTimer invalidate];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //Deletes users location whenever the app is terminated
    if ([PFUser currentUser] != nil)
    {
        [[PFUser currentUser] setObject:[NSNull null] forKey:@"location"];
        [[PFUser currentUser] save];
    }
    else
    {
        return;
    }
}

@end
