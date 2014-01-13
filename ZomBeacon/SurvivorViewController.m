//
//  SurvivorViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 12/11/13.
//  Copyright (c) 2013 Patrick Adams. All rights reserved.
//

#import "SurvivorViewController.h"

@interface SurvivorViewController ()

@end

@implementation SurvivorViewController
{
    BOOL isInfected;
    int minutes, seconds;
    int secondsLeft;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];

    [self initRegion];
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    PFUser *user = [PFUser currentUser];
    
//    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
//        if (!error) {
//            PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
//            [user setObject:point forKey:@"location"];
//            [user setObject:@"survivor" forKey:@"status"];
//            [user saveInBackground];
//        }
//    }];
    
    if (user[@"location"]) {
        PFGeoPoint *userGeoPoint = user[@"location"];
        PFQuery *query = [PFUser query];
        query.limit = 30;
        [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:0.05];
        NSArray *nearbyUsers = [query findObjects];
        
        for (int i = 0; i < nearbyUsers.count ; i++) {
            PFGeoPoint *geoPointsForNearbyUsers = nearbyUsers[i][@"location"];
            NSString *nameOfNearbyUsers = nearbyUsers[i][@"name"];
            NSLog(@"Username: %@, Latitude: %f, Longitude: %f", nameOfNearbyUsers, geoPointsForNearbyUsers.latitude, geoPointsForNearbyUsers.longitude);
        }


    } else {
        NSLog(@"No location found reload");
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    MKCoordinateRegion mapRegion;
    mapRegion.center = newLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.005;
    mapRegion.span.longitudeDelta = 0.005;
    
    [self.mapView setRegion:mapRegion animated:YES];
}

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
        self.warningText.hidden = NO;
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    
    if (beacon.proximity == CLProximityImmediate && isInfected == NO)
    {
        UIStoryboard *storyboard;
        if(IS_IPAD)
        {
            storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        }
        else
        {
            storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        }
        
        InfectedViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"infected"];
        [self.navigationController pushViewController:vc animated:YES];
        vc.infectedLabel.text = @"YOU ARE NOW INFECTED";
        isInfected = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
