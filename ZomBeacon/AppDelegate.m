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
    
    //Initializes the Facebook SDK
    [PFFacebookUtils initializeFacebook];
    
    //Lets me use the PFImageView class in place of a UIImageView
    [PFImageView class];
    
    //Initializes the Twitter SDK
    [PFTwitterUtils initializeWithConsumerKey:@"4Oj2HtCnI9e8ALYhApmEyg"
                               consumerSecret:@"q0wXLhwm6qSdEiM1BmnPEcfYYJ36HbASJ62WENgEBo"];
    
    //Bluetooth Peripheral Manager
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    
    //Proximity Kit
    self.proximityKitManager = [PKManager managerWithDelegate:self];
    [self.proximityKitManager start];
    
    return YES;
}

#pragma mark - ProximityKit delegate methods

- (void)proximityKit:(PKManager *)manager didEnter:(PKRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Entered a safe zone!";
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)proximityKit:(PKManager *)manager didExit:(PKRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Exited a safe zone!";
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

#pragma mark - Core Bluetooth

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"%@", peripheral);
    NSString *userStatus = [PFUser currentUser][@"publicStatus"];
    
    if ([userStatus isEqualToString:@"zombie"])
    {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"PUBLIC GAME: A survivor is nearby, bite them!";
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
    else if ([userStatus isEqualToString:@"survivor"])
    {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"PUBLIC GAME: A zombie is nearby, headshot them!";
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        NSString *userStatus = [PFUser currentUser][@"publicStatus"];
        
        if ([userStatus isEqualToString:@"survivor"])
        {
            self.peripheralCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"23B1DEB4-5061-423A-A341-C5FFDB2CDE36"] properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyWrite|CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
            
            self.peripheralService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:@"A609D670-B7FF-4098-89CF-D5E67720CEC2"] primary:YES];
            [self.peripheralService setCharacteristics:@[self.peripheralCharacteristic]];
            
            [self.peripheralManager addService:self.peripheralService];
        }
        else if ([userStatus isEqualToString:@"zombie"])
        {
            self.peripheralCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"23B1DEB4-5061-423A-A341-C5FFDB2CDE36"] properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyWrite|CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
            
            self.peripheralService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:@"307D9B00-053B-4849-8222-47E4BD3AB0B7"] primary:YES];
            [self.peripheralService setCharacteristics:@[self.peripheralCharacteristic]];
            
            [self.peripheralManager addService:self.peripheralService];
        }
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    NSString *userStatus = [PFUser currentUser][@"publicStatus"];
    
    if (error)
    {
        NSLog(@"Error publishing service: %@", [error localizedDescription]);
    }
    else if ([userStatus isEqualToString:@"survivor"])
    {
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:@"A609D670-B7FF-4098-89CF-D5E67720CEC2"]]}];
    }
    else if ([userStatus isEqualToString:@"zombie"])
    {
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:@"307D9B00-053B-4849-8222-47E4BD3AB0B7"]]}];
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
        
        NSString *userStatus = [PFUser currentUser][@"publicStatus"];
        
        if ([userStatus isEqualToString:@"survivor"])
        {
            [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"307D9B00-053B-4849-8222-47E4BD3AB0B7"]] options:nil];
        }
        else if ([userStatus isEqualToString:@"zombie"])
        {
            [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"A609D670-B7FF-4098-89CF-D5E67720CEC2"]] options:nil];
        }
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
    
    //Bluetooth Central Manager
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
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
    [self.queryEnemiesTimer invalidate];
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
