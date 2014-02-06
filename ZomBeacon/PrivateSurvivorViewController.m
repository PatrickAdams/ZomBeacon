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
    BOOL isZombie;
    int minutes, seconds;
    int secondsLeft;
}

- (void)viewDidLoad
{
    self.mapView.delegate = self;
    [super viewDidLoad];
    [self queryNearbyUsers];
}

- (void)viewDidAppear:(BOOL)animated
{
    currentUser = [PFUser currentUser];
    [currentUser setObject:@"survivor" forKey:@"privateStatus"];
    [currentUser saveInBackground];
    
    [self queryNearbyUsers];
    [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(queryNearbyUsers) userInfo:nil repeats:YES];
    
    //MapView stuff
    [self.locationManager startUpdatingLocation];
    [self zoomToUserLocation:self.mapView.userLocation];
    
    //Beacon stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self initRegion];
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
    
    isZombie = NO;
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
        [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:0.5];
        [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
            if (!error) {
                
                // First remove all annotations to refresh the status of them
                UserAnnotations *newAnnotation;
                [self.mapView removeAnnotations:self.mapView.annotations];
                
                //Start at int = 1 so that the query doesn't include yourself
                for (int i = 1; i < users.count ; i++)
                {
                    PFGeoPoint *geoPointsForNearbyUser = users[i][@"location"];
                    NSString *nameOfNearbyUser = users[i][@"name"];
                    NSString *statusOfNearbyUser = users[i][@"privateStatus"];
                    
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
    [self.mapView setRegion:region animated:NO];
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

//Beacon ranging setup
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

//Initializes the beacon region
- (void)initRegion
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"12345678-1234-1234-1234-123456789012"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.patrickadams.theRegion"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
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

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];
    
    if (beacon.proximity == CLProximityNear) //Change to (beacon.proximity == CLProximityFar) whenever testing outside
    {
//        self.warningText.hidden = NO;
//        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
//        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    
    if (beacon.proximity == CLProximityImmediate && isZombie == NO)
    {
        // present local notification
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"You've been infected by a zombie, go find some survivors!";
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        PrivateZombieViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"privateZombie"];
        [self.navigationController pushViewController:vc animated:YES];
        isZombie = YES;
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
