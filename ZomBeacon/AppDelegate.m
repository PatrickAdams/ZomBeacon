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
    
    //TestFlight analytics
    [TestFlight takeOff:@"5b141d23-4474-4887-b544-9d01461fe8f0"];
    
    //Lets me use the PFImageView class in place of a UIImageView
    [PFImageView class];
    
    //Initializes the Twitter SDK
    [PFTwitterUtils initializeWithConsumerKey:@"4Oj2HtCnI9e8ALYhApmEyg"
                               consumerSecret:@"q0wXLhwm6qSdEiM1BmnPEcfYYJ36HbASJ62WENgEBo"];
    
//    // create and start to sync the manager with the Proximity Kit backend
//    self.proximityKitManager = [PKManager managerWithDelegate:self];
//    [self.proximityKitManager start];
    
    //Bluetooth 
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [self centralManagerDidUpdateState:self.centralManager];
    
    self.currentUser = [PFUser currentUser];
    
    return YES;
}

#pragma mark - Facebook Setup

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return
    
    [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

#pragma mark - Proximity Kit

//Presents local notification when user enters proximity kit geofence
- (void)proximityKit:(PKManager *)manager didEnter:(PKRegion *)region
{
    // present local notification
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"You've entered the game region!";
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

//Presents local notification when user exits proximity kit geofence
- (void)proximityKit:(PKManager *)manager didExit:(PKRegion *)region
{
    // present local notification
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"You are out of bounds, return or you will be disqualified.";
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

#pragma mark - Application State Methods

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    [self saveLocation];
    
    //Will save user's location every 5 minutes when enters background
    self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:300.0f target:self selector:@selector(saveLocation) userInfo:nil repeats:YES];
}

- (void)saveLocation
{
    if (self.currentUser)
    {
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            [self.currentUser setObject:geoPoint forKey:@"location"];
            [self.currentUser saveInBackground];
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //Deletes users location whenever the app is terminated
    if (self.currentUser)
    {
        [self.currentUser setObject:[NSNull null] forKey:@"location"];
        [self.currentUser save];
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
