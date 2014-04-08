//
//  PrivateZombieViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 12/11/13.
//  Copyright (c) 2013 Patrick Adams. All rights reserved.
//

#import "PrivateZombieViewController.h"

@interface PrivateZombieViewController ()

@end

@implementation PrivateZombieViewController

- (void)viewDidLoad
{
    currentUser = [PFUser currentUser];
    self.navigationItem.hidesBackButton = YES;
    
    [self queryNearbyUsers];
    
    [super viewDidLoad];
    
    //MapView Stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.mapView.delegate = self;
    
    mapKeyShowing = NO;
    
    //Grabs UUID from game so that the iBeacon is unique to the game
    PFQuery *uuidQuery = [PFQuery queryWithClassName:@"PrivateGames"];
    [uuidQuery whereKey:@"objectId" equalTo:currentUser[@"currentGame"]];
    PFObject *currentGame = [uuidQuery getFirstObject];
    
    //Setting up beacon for bites
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:currentGame[@"uuid"]];
    CLBeaconMajorValue major = [currentUser[@"major"] unsignedShortValue];
    CLBeaconMajorValue minor = [currentUser[@"minor"] unsignedShortValue];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:@"com.zombeacon.privateRegion"];
    
    //Initializing beacon region to range for headshots
    NSUUID *uuid2 = [[NSUUID alloc] initWithUUIDString:currentGame[@"uuid2"]];
    self.beaconRegion2 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid2 identifier:@"com.zombeacon.privateRegion"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion2];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion2];
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(validateTimer) name:UIApplicationDidBecomeActiveNotification object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(removeUser) name:UIApplicationWillTerminateNotification object: nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self queryNearbyUsers];
    self.queryTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(queryNearbyUsers) userInfo:nil repeats:YES];
    
    //MapView stuff
    [self zoomToUserLocation:self.locationManager.location];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.queryTimer invalidate];
}

- (void)validateTimer
{
    self.queryTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(queryNearbyUsers) userInfo:nil repeats:YES];
}

#pragma mark - Parse: Nearby User Querying with Custom Annotations

//Queries all nearby users and adds them to the mapView
- (void)queryNearbyUsers
{    
    PFQuery *countsQuery = [PFQuery queryWithClassName:@"PrivateGames"];
    [countsQuery whereKey:@"objectId" equalTo:currentUser[@"currentGame"]];
    PFObject *currentGame = [countsQuery getFirstObject];
    NSNumber *zombieCount = currentGame[@"zombieCount"];
    NSNumber *survivorCount = currentGame[@"survivorCount"];
    
    if ([zombieCount intValue] < 1 || [survivorCount intValue] < 1)
    {
        [self performSegueWithIdentifier: @"endGamePrivateZombie" sender:self];
        for (UIViewController *controller in [self.navigationController viewControllers])
        {
            if ([controller isKindOfClass:[PrivateLobbyViewController class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
                break;
            }
        }
    }
    
    self.zombieCount.text = [NSString stringWithFormat:@"%@", currentGame[@"zombieCount"]];
    self.survivorCount.text = [NSString stringWithFormat:@"%@", currentGame[@"survivorCount"]];
    
    if (currentUser[@"location"])
    {
        PFGeoPoint *userGeoPoint = currentUser[@"location"];
        PFQuery *query = [PFUser query];
        [query whereKey:@"currentGame" equalTo:currentUser[@"currentGame"]];
        [query whereKey:@"objectId" notEqualTo:currentUser.objectId];
        [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:1.0];
        [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
            if (!error)
            {
                // First remove all annotations to refresh the status of them
                UserAnnotations *newAnnotation;
                [self.mapView removeAnnotations:self.mapView.annotations];
                
                //Start at int = 1 so that the query doesn't include yourself
                for (int i = 0; i < users.count ; i++)
                {
                    PFGeoPoint *geoPointsForNearbyUser = users[i][@"location"];
                    NSString *nameOfNearbyUser = users[i][@"username"];
                    
                    PFQuery *privateStatusQuery = [PFQuery queryWithClassName:@"PrivateStatus"];
                    [privateStatusQuery whereKey:@"user" equalTo:users[i]];
                    PFObject *privateStatus = [privateStatusQuery getFirstObject];
                    
                    NSString *statusOfNearbyUser = privateStatus[@"status"];
                    
                    // Set some coordinates for our position
                    CLLocationCoordinate2D location;
                    location.latitude = (double) geoPointsForNearbyUser.latitude;
                    location.longitude = (double) geoPointsForNearbyUser.longitude;
                    
                    if ([statusOfNearbyUser isEqualToString:@"survivor"])
                    {
                        newAnnotation = [[UserAnnotations alloc] initWithTitle:nameOfNearbyUser andCoordinate:location andImage:[UIImage imageNamed:@"survivor_annotation"]];
                    }
                    else if ([statusOfNearbyUser isEqualToString:@"zombie"])
                    {
                        newAnnotation = [[UserAnnotations alloc] initWithTitle:nameOfNearbyUser andCoordinate:location andImage:[UIImage imageNamed:@"zb_annotation"]];
                    }
                    
                    [self.mapView addAnnotation:newAnnotation];
                }
            }
        }];
    }
}

//Adds annotations to the mapView
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[UserAnnotations class]])
    {
        UserAnnotations *userLocations = (UserAnnotations *)annotation;
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"UserLocations"];
        
        if (annotationView == nil)
        {
            annotationView = userLocations.annotationView;
        }
        else
        {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    else
    {
        return nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CLBeacon *beacon = [beacons lastObject];
    
    if (beacon.proximity == CLProximityNear || beacon.proximity == CLProximityImmediate)
    {
        [manager stopRangingBeaconsInRegion:region];
        PFQuery *countsQuery = [PFQuery queryWithClassName:@"PrivateGames"];
        [countsQuery whereKey:@"objectId" equalTo:currentUser[@"currentGame"]];
        PFObject *currentGame = [countsQuery getFirstObject];
        int survivorCount = [currentGame[@"survivorCount"] intValue];
        int zombieCount = [currentGame[@"zombieCount"] intValue];
        
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"minor" equalTo:beacon.minor];
        [userQuery whereKey:@"major" equalTo:beacon.major];
        PFUser *userThatInfected = (PFUser *)[userQuery getFirstObject];
        
        PFQuery *query = [PFQuery queryWithClassName:@"PrivateStatus"];
        [query whereKey:@"user" equalTo:currentUser];
        PFObject *theStatus = [query getFirstObject];
        [theStatus setObject:@"dead" forKey:@"status"];
        [theStatus saveInBackground];
        
        zombieCount--;
        
        currentGame[@"survivorCount"] = [NSNumber numberWithInt:survivorCount];
        currentGame[@"zombieCount"] = [NSNumber numberWithInt:zombieCount];
        [currentGame save];
        
        if (zombieCount < 1)
        {
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PRIVATE GAME" message:[NSString stringWithFormat:@"You just got headshotted by %@. GAME OVER!", userThatInfected.username] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
                
                //Set up push to send to person that shot you.
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"owner" equalTo:userThatInfected];
                
                PFPush *push = [PFPush new];
                [push setQuery:pushQuery];
                [push setData:@{ @"alert": [NSString stringWithFormat:@"Nice! You headshotted user: %@ to win the game! +400 pts", currentUser.username] }];
                [push sendPush:nil];
                
                //Adds 400 pts to the user's publicScore for a bite
                [self assignPointsFor:userThatInfected pointTotal:400.0f];

            }
            else
            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.alertBody = [NSString stringWithFormat:@"PRIVATE GAME: You just got headshotted by %@. GAME OVER!", userThatInfected.username];
                notification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                
                //Set up push to send to person that shot you.
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"owner" equalTo:userThatInfected];
                
                PFPush *push = [PFPush new];
                [push setQuery:pushQuery];
                [push setData:@{ @"alert": [NSString stringWithFormat:@"Nice! You headshotted user: %@ to win the game! +400 pts", currentUser.username] }];
                [push sendPush:nil];
                
                //Adds 400 pts to the user's publicScore for a bite
                [self assignPointsFor:userThatInfected pointTotal:400.0f];

            }

            [self performSegueWithIdentifier:@"endGamePrivateZombie" sender:self];
            for (UIViewController *controller in [self.navigationController viewControllers])
            {
                if ([controller isKindOfClass:[PrivateLobbyViewController class]])
                {
                    [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
        }
        else
        {
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PRIVATE GAME" message:[NSString stringWithFormat:@"You just got headshotted by %@. You are dead!", userThatInfected.username] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
                
                //Set up push to send to person that shot you.
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"owner" equalTo:userThatInfected];
                
                PFPush *push = [PFPush new];
                [push setQuery:pushQuery];
                [push setData:@{ @"alert": [NSString stringWithFormat:@"Nice! You headshotted user %@ for +200 pts!", currentUser.username] }];
                [push sendPush:nil];
                
                //Adds 200 pts to the user's publicScore for a bite
                [self assignPointsFor:userThatInfected pointTotal:200.0f];

            }
            else
            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.alertBody = [NSString stringWithFormat:@"PRIVATE GAME: You just got headshotted by %@. You are dead!", userThatInfected.username];
                notification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                
                //Set up push to send to person that shot you.
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"owner" equalTo:userThatInfected];
                
                PFPush *push = [PFPush new];
                [push setQuery:pushQuery];
                [push setData:@{ @"alert": [NSString stringWithFormat:@"Nice! You headshotted user %@ for +200 pts!", currentUser.username] }];
                [push sendPush:nil];
                
                //Adds 100 pts to the user's publicScore for a bite
                [self assignPointsFor:userThatInfected pointTotal:200.0f];
            }

            [self performSegueWithIdentifier:@"privateDead" sender:self];
        }
    }
}

- (void)assignPointsFor:(PFUser *)userThatInfected pointTotal:(float)points
{
    //Adds 100 pts to the user's publicScore for a bite
    PFQuery *query2 = [PFQuery queryWithClassName:@"UserScore"];
    [query2 whereKey:@"user" equalTo:userThatInfected];
    PFObject *theUserScore = [query2 getFirstObject];
    float score = [theUserScore[@"privateScore"] floatValue];
    NSNumber *sum = [NSNumber numberWithFloat:score + points];
    [theUserScore setObject:sum forKey:@"privateScore"];
    [theUserScore saveInBackground];
}

- (void)removeUser
{
    PFQuery *query = [PFQuery queryWithClassName:@"PrivateStatus"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    PFObject *theStatus = [query getFirstObject];
    NSString *privateStatus = theStatus[@"status"];
    
    PFQuery *privateGame = [PFQuery queryWithClassName:@"PrivateGames"];
    [privateGame whereKey:@"objectId" equalTo:currentUser[@"currentGame"]];
    PFObject *currentGame = [privateGame getFirstObject];
    int survivorCount = [currentGame[@"survivorCount"] intValue];
    int zombieCount = [currentGame[@"zombieCount"] intValue];
    
    if ([privateStatus isEqualToString:@"survivor"])
    {
        survivorCount--;
    }
    else if ([privateStatus isEqualToString:@"zombie"])
    {
        zombieCount--;
    }
    
    currentGame[@"survivorCount"] = [NSNumber numberWithInt:survivorCount];
    currentGame[@"zombieCount"] = [NSNumber numberWithInt:zombieCount];
    [currentGame save];
    
    [theStatus setObject:@"" forKey:@"status"];
    [theStatus saveInBackground];
}

#pragma mark - Location Management

//Method to zoom to the user location
- (void)zoomToUserLocation:(CLLocation *)userLocation
{
    if (!userLocation)
        return;
    
    MKCoordinateRegion region;
    region.center = userLocation.coordinate;
    region.span = MKCoordinateSpanMake(0.002, 0.002); //Zoom distance
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

//For the compass button on the map
- (IBAction)trackMyOrientation
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    [UIView animateWithDuration:0.5 animations:^{self.locationButton.alpha = 1.0;}];
    [UIView animateWithDuration:0.5 animations:^{self.compassButton.alpha = 0.0;}];
}

//For the crosshairs button on the map
- (IBAction)centerMapOnLocation
{
    [self zoomToUserLocation:self.locationManager.location];
    [UIView animateWithDuration:0.5 animations:^{self.locationButton.alpha = 0.0;}];
    [UIView animateWithDuration:0.5 animations:^{self.compassButton.alpha = 1.0;}];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [UIView animateWithDuration:0.5 animations:^{self.locationButton.alpha = 1.0;}];
    [UIView animateWithDuration:0.5 animations:^{self.compassButton.alpha = 0.0;}];
}

- (IBAction)showMapKey
{
    if (mapKeyShowing == NO)
    {
        [UIView animateWithDuration:0.5 animations:^{self.mapKeyView.alpha = 1.0;}];
        mapKeyShowing = YES;
    }
    else if (mapKeyShowing == YES)
    {
        [UIView animateWithDuration:0.5 animations:^{self.mapKeyView.alpha = 0.0;}];
        mapKeyShowing = NO;
    }
}


#pragma mark - Beacon Management

//Method that starts the transmission of the beacon
- (IBAction)startInfecting:(id)sender
{
    [self playBiteSound];
    self.beaconPeripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(stopInfecting) userInfo:nil repeats:NO];
}

- (void)stopInfecting
{
    [self.peripheralManager stopAdvertising];
}

- (void)playBiteSound
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"zombie_bite" withExtension: @"wav"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer play];
}

//Method that tracks the beacon activity
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        [self.peripheralManager startAdvertising:self.beaconPeripheralData];
    }
    else if (peripheral.state == CBPeripheralManagerStatePoweredOff)
    {
        [self.peripheralManager stopAdvertising];
    }
}

#pragma mark - Closing Methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end