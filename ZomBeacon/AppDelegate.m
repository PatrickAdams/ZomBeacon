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
    
    //Bluetooth
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [self centralManagerDidUpdateState:self.centralManager];
    
    return YES;
}

#pragma mark - Custom URL Implementation

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]])
    {
        [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
    }
    else
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
    notified1 = NO;
    notifiedMore = NO;
    
    //Starts location manager to track user location in the background
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    if ([PFUser currentUser] != nil)
    {
        //Will save user's location every 3 seconds when enters background
        self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(saveLocation) userInfo:nil repeats:YES];
        
        self.queryEnemiesTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(queryEnemies) userInfo:nil repeats:YES];
    }
}

- (void)queryEnemies
{
    if ([PFUser currentUser] != nil)
    {
        if ([PFUser currentUser][@"location"] && [[PFUser currentUser][@"publicStatus"] isEqualToString:@"survivor"])
        {
            PFGeoPoint *userGeoPoint = [PFUser currentUser][@"location"];
            PFQuery *query = [PFUser query];
            [query whereKey:@"joinedPublic" equalTo:@"YES"];
            [query whereKey:@"publicStatus" equalTo:@"zombie"];
            [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:0.004];
            [query findObjectsInBackgroundWithBlock:^(NSArray *zombies, NSError *error) {
                if (!error)
                {
                    //Presents the local notification
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    if (zombies.count == 1 && notified1 == NO)
                    {
                        notification.alertBody = [NSString stringWithFormat:@"PUBLIC GAME: There is %lu zombie very close to you. Check your map!", (unsigned long)zombies.count];
                        notification.soundName = UILocalNotificationDefaultSoundName;
                        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                        notified1 = YES;
                    }
                    else if (zombies.count > 1 && notifiedMore == NO)
                    {
                        notification.alertBody = [NSString stringWithFormat:@"PUBLIC GAME: There are %lu zombies very close to you. Check your map!", (unsigned long)zombies.count];
                        notification.soundName = UILocalNotificationDefaultSoundName;
                        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                        notifiedMore = YES;
                    }
                    else if (zombies.count == 0)
                    {
                        notified1 = NO;
                        notifiedMore = NO;
                    }
                    
                }
            }];
        }
        else if ([PFUser currentUser][@"location"] && [[PFUser currentUser][@"publicStatus"] isEqualToString:@"zombie"])
        {
            PFGeoPoint *userGeoPoint = [PFUser currentUser][@"location"];
            PFQuery *query = [PFUser query];
            [query whereKey:@"joinedPublic" equalTo:@"YES"];
            [query whereKey:@"publicStatus" equalTo:@"survivor"];
            [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:0.004];
            [query findObjectsInBackgroundWithBlock:^(NSArray *survivors, NSError *error) {
                if (!error)
                {
                    //Presents the local notification
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    if (survivors.count == 1 && notified1 == NO)
                    {
                        notification.alertBody = [NSString stringWithFormat:@"PUBLIC GAME: There is %lu survivor very close to you. Check your map!", (unsigned long)survivors.count];
                        notification.soundName = UILocalNotificationDefaultSoundName;
                        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                        notified1 = YES;
                    }
                    else if (survivors.count > 1 && notifiedMore == NO)
                    {
                        notification.alertBody = [NSString stringWithFormat:@"PUBLIC GAME: There are %lu survivors very close to you. Check your map!", (unsigned long)survivors.count];
                        notification.soundName = UILocalNotificationDefaultSoundName;
                        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                        notifiedMore = YES;
                    }
                    else if (survivors.count == 0)
                    {
                        notified1 = NO;
                        notifiedMore = NO;
                    }
                }
            }];
        }
    }
}

- (void)saveLocation
{
    if ([PFUser currentUser] != nil)
    {
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            [[PFUser currentUser] setObject:geoPoint forKey:@"location"];
            [[PFUser currentUser] saveInBackground];
        }];
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

#pragma mark - Bluetooth Check

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //Shows blue tooth warning view controller if bluetooth is not enabled
    if (central.state == CBCentralManagerStatePoweredOff)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"bluetooth"];
        [self.window.rootViewController presentViewController:vc animated:NO completion:nil];
    }
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
