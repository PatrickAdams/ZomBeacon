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
    [super viewDidLoad];
    
    self.currentUser = [PFUser currentUser];
    
    self.mapView.delegate = self;
    [self queryNearbyUsers];
    
    //Beacon & MapView stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    //Grabs UUID from game so that the iBeacon is unique to the game
    PFQuery *uuidQuery = [PFQuery queryWithClassName:@"PrivateGames"];
    [uuidQuery whereKey:@"objectId" equalTo:self.currentUser[@"currentGame"]];
    PFObject *currentGame = [uuidQuery getFirstObject];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:currentGame[@"uuid"]];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:1 minor:1 identifier:@"com.zombeacon.privateRegion"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
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

- (IBAction)activateShield
{
    [self.shieldButton setEnabled:NO];
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    self.shieldTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(startRangingAgain) userInfo:nil repeats:NO];
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
    [self.currentUser setObject:point forKey:@"location"];
    [self.currentUser saveInBackground];

    if (self.currentUser[@"location"])
    {
        PFGeoPoint *userGeoPoint = self.currentUser[@"location"];
        PFQuery *query = [PFUser query];
        [query whereKey:@"currentGame" equalTo:self.currentUser[@"currentGame"]];
        [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:1.0];
        [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
            if (!error)
            {
                // First remove all annotations to refresh the status of them
                UserAnnotations *newAnnotation;
                [self.mapView removeAnnotations:self.mapView.annotations];
                
                //Start at int = 1 so that the query doesn't include yourself
                for (int i = 1; i < users.count ; i++)
                {
                    PFGeoPoint *geoPointsForNearbyUser = users[i][@"location"];
                    NSString *nameOfNearbyUser = users[i][@"name"];
                    
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
                        newAnnotation = [[UserAnnotations alloc] initWithTitle:nameOfNearbyUser andCoordinate:location andImage:[UIImage imageNamed:@"blue"]];
                    }
                    else if ([statusOfNearbyUser isEqualToString:@"zombie"])
                    {
                        newAnnotation = [[UserAnnotations alloc] initWithTitle:nameOfNearbyUser andCoordinate:location andImage:[UIImage imageNamed:@"red"]];
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
        // present local notification
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"PRIVATE GAME: You've been bitten by a zombie, you are now infected. Go find some Survivors!";
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
        PFQuery *query = [PFQuery queryWithClassName:@"PrivateStatus"];
        [query whereKey:@"user" equalTo:self.currentUser];
        PFObject *theStatus = [query getFirstObject];
        [theStatus setObject:@"zombie" forKey:@"status"];
        [theStatus saveInBackground];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PrivateZombieViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"privateZombie"];
        vc.navigationItem.hidesBackButton = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
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
