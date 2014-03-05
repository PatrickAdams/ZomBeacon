//
//  PrivateSurvivorViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 12/11/13.
//  Copyright (c) 2013 Patrick Adams. All rights reserved.
//

#import "PrivateSurvivorViewController.h"

@interface PrivateSurvivorViewController ()

@end

@implementation PrivateSurvivorViewController
{
    int minutes, seconds;
    int secondsLeft;
}

- (void)viewDidLoad
{
    currentUser = [PFUser currentUser];
    
    [self queryNearbyUsers];
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    
    //Beacon & MapView stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    //Grabs UUID from game so that the iBeacon is unique to the game
    PFQuery *uuidQuery = [PFQuery queryWithClassName:@"PrivateGames"];
    [uuidQuery whereKey:@"objectId" equalTo:currentUser[@"currentGame"]];
    PFObject *currentGame = [uuidQuery getFirstObject];
    
    //Initializing beacon reagon to range for bites
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:currentGame[@"uuid"]];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.zombeacon.privateRegion"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    //Setting up beacon for headshots
    NSUUID *uuid2 = [[NSUUID alloc] initWithUUIDString:currentGame[@"uuid2"]];
    CLBeaconMajorValue major = [currentUser[@"major"] unsignedShortValue];
    CLBeaconMajorValue minor = [currentUser[@"minor"] unsignedShortValue];
    self.beaconRegion2 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid2 major:major minor:minor identifier:@"com.zombeacon.privateRegion"];
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    self.queryTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(queryNearbyUsers) userInfo:nil repeats:YES];
    
    //MapView stuff
    [self.locationManager startUpdatingLocation];
    [self zoomToUserLocation:self.mapView.userLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.queryTimer invalidate];
}

- (void)startRangingAgain
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

#pragma mark - Parse: Nearby User Querying with Custom Annotations

//Queries all nearby users and adds them to the mapView
- (void)queryNearbyUsers
{
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.mapView.userLocation.coordinate.latitude longitude:self.mapView.userLocation.coordinate.longitude];
    [currentUser setObject:point forKey:@"location"];
    [currentUser saveInBackground];

    if (currentUser[@"location"])
    {
        PFGeoPoint *userGeoPoint = currentUser[@"location"];
        PFQuery *query = [PFUser query];
        [query whereKey:@"currentGame" equalTo:currentUser[@"currentGame"]];
        [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:2.0];
        [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
            if (!error)
            {
                // First remove all annotations to refresh the status of them
                UserAnnotations *newAnnotation;
                [self.mapView removeAnnotations:self.mapView.annotations];
                
                int zombieCount = 0;
                int survivorCount = 0;
                
                //Start at int = 1 so that the query doesn't include yourself
                for (int i = 1; i < users.count ; i++)
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
                        survivorCount++;
                        newAnnotation = [[UserAnnotations alloc] initWithTitle:nameOfNearbyUser andCoordinate:location andImage:[UIImage imageNamed:@"survivor_annotation"]];
                    }
                    else if ([statusOfNearbyUser isEqualToString:@"zombie"])
                    {
                        zombieCount++;
                        newAnnotation = [[UserAnnotations alloc] initWithTitle:nameOfNearbyUser andCoordinate:location andImage:[UIImage imageNamed:@"zombie_annotation"]];
                    }
                    
                    [self.mapView addAnnotation:newAnnotation];
                }
                
                PFQuery *currentUserPrivateStatusQuery = [PFQuery queryWithClassName:@"PrivateStatus"];
                [currentUserPrivateStatusQuery whereKey:@"user" equalTo:currentUser];
                PFObject *currentUserPrivateStatus = [currentUserPrivateStatusQuery getFirstObject];
                
                if ([currentUserPrivateStatus[@"status"] isEqualToString:@"zombie"])
                {
                    zombieCount++;
                }
                else if ([currentUserPrivateStatus[@"status"] isEqualToString:@"survivor"])
                {
                    survivorCount++;
                }
                
                self.zombieCount.text = [NSString stringWithFormat:@"%d", zombieCount];
                self.survivorCount.text = [NSString stringWithFormat:@"%d", survivorCount];
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

#pragma mark - Location Management

//Method to zoom to the user location
- (void)zoomToUserLocation:(MKUserLocation *)userLocation
{
    if (!userLocation)
    {
        return;
    }
    
    MKCoordinateRegion region;
    region.center = userLocation.location.coordinate;
    region.span = MKCoordinateSpanMake(0.002, 0.002); //Zoom distance
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

//For the compass button on the map
- (IBAction)trackMyOrientation
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
}

//For the crosshairs button on the map
- (IBAction)centerMapOnLocation
{
    [self zoomToUserLocation:self.mapView.userLocation];
}

#pragma mark - Beacon Management

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CLBeacon *beacon = [beacons lastObject];
    
    if (beacon.proximity == CLProximityNear || beacon.proximity == CLProximityImmediate)
    {
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"minor" equalTo:beacon.minor];
        [userQuery whereKey:@"major" equalTo:beacon.major];
        PFUser *userThatInfected = (PFUser *)[userQuery getFirstObject];
        
        // present local notification
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = [NSString stringWithFormat:@"PRIVATE GAME: You've been bitten by user: %@, you are now infected. Go find some Survivors!", userThatInfected.username];
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
        PFQuery *query = [PFQuery queryWithClassName:@"PrivateStatus"];
        [query whereKey:@"user" equalTo:currentUser];
        PFObject *theStatus = [query getFirstObject];
        [theStatus setObject:@"zombie" forKey:@"status"];
        [theStatus saveInBackground];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PrivateZombieViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"privateZombie"];
        vc.navigationItem.hidesBackButton = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
        //Adds 250 pts to the user's publicScore for a bite
        PFQuery *query2 = [PFQuery queryWithClassName:@"UserScore"];
        [query2 whereKey:@"user" equalTo:userThatInfected];
        PFObject *theUserScore = [query2 getFirstObject];
        float score = [theUserScore[@"privateScore"] floatValue];
        float points = 250.0f;
        NSNumber *sum = [NSNumber numberWithFloat:score + points];
        [theUserScore setObject:sum forKey:@"privateScore"];
        [theUserScore saveInBackground];
        
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    }
}

//Method that starts the transmission of the headshot
- (IBAction)headshotTheZombie:(id)sender
{
    self.beaconPeripheralData = [self.beaconRegion2 peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    [self.headshotButton setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(stopTheHeadshot) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(enableHeadshot) userInfo:nil repeats:NO];
}

- (void)stopTheHeadshot
{
    [self.peripheralManager stopAdvertising];
}

- (void)enableHeadshot
{
    [self.headshotButton setEnabled:YES];
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

#pragma mark - Time Counter Management

//Method to start a countdown timer
- (IBAction)startCounter
{
    secondsLeft = 600;
    [self countdownTimer];
}

//Method that refreshes and updates the countdown timer
- (void)updateCounter:(NSTimer *)theTimer
{
    if(secondsLeft > 0 )
    {
        secondsLeft -- ;
        minutes = (secondsLeft % 3600) / 60;
        seconds = (secondsLeft %3600) % 60;
        self.myCounterLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    else
    {
        secondsLeft = 600;
    }
}

//Method that does the setup for the countdown timer
- (void)countdownTimer
{
    secondsLeft = minutes = seconds = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
}

#pragma mark - Closing Methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
