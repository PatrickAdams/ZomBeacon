//
//  PublicZombieViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 2/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "PublicZombieViewController.h"

@interface PublicZombieViewController ()

@end

@implementation PublicZombieViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentUser = [PFUser currentUser];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.mapView.delegate = self;
    [self queryNearbyUsers];
    
    //MapView Stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    //Initializing beacon region to send to survivors
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"1DC4825D-7457-474D-BE7B-B4C9B2D1C763"];
    CLBeaconMajorValue major = [currentUser[@"major"] unsignedShortValue];
    CLBeaconMajorValue minor = [currentUser[@"minor"] unsignedShortValue];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:@"com.zombeacon.publicRegion"];
    
    //Initializing beacon region to range for headshots
    NSUUID *uuid2 = [[NSUUID alloc] initWithUUIDString:@"6170CEEF-4D17-4741-8068-850A601E32F0"];
    self.beaconRegion2 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid2 identifier:@"com.zombeacon.publicRegion"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion2];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion2];
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style: UIBarButtonItemStyleBordered target:self action:@selector(backHome)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)backHome
{
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[MainMenuViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.locationManager startUpdatingLocation];
    
    self.queryTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(queryNearbyUsers) userInfo:nil repeats:YES];
    
    //Zoom to user location once
    [self zoomToUserLocation:self.mapView.userLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.queryTimer invalidate];
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
        [query whereKey:@"joinedPublic" equalTo:@"YES"];
        [query whereKey:@"objectId" notEqualTo:currentUser.objectId];
        [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:0.25];
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
                    NSString *statusOfNearbyUser = users[i][@"publicStatus"];
                    
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
                        newAnnotation = [[UserAnnotations alloc] initWithTitle:nameOfNearbyUser andCoordinate:location andImage:[UIImage imageNamed:@"zombie_annotation"]];
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
    double miles = 0.5;
    double scalingFactor = ABS( (cos(2 * M_PI * userLocation.coordinate.latitude / 360.0) ));
    
    MKCoordinateSpan span;
    span.latitudeDelta = miles/69.0;
    span.longitudeDelta = miles/(scalingFactor * 69.0);
    
    MKCoordinateRegion region;
    region.center = userLocation.coordinate;
    region.span = span;
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
    CLBeacon *beacon = [beacons firstObject];
        
    if (beacon.proximity == CLProximityNear || beacon.proximity == CLProximityImmediate)
    {
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion2];
        
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"minor" equalTo:beacon.minor];
        [userQuery whereKey:@"major" equalTo:beacon.major];
        PFUser *userThatInfected = (PFUser *)[userQuery getFirstObject];
        
        // present local notification
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = [NSString stringWithFormat:@"You just got headshotted by %@!", userThatInfected.username];
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
        [currentUser setObject:@"dead" forKey:@"publicStatus"];
        [currentUser saveInBackground];
        
        [self performSegueWithIdentifier: @"publicDead" sender: self];
        
        PFQuery *query = [PFQuery queryWithClassName:@"UserScore"];
        [query whereKey:@"user" equalTo:userThatInfected];
        PFObject *theUserScore = [query getFirstObject];
        float score = [theUserScore[@"publicScore"] floatValue];
        float points = 500.0f;
        NSNumber *sum = [NSNumber numberWithFloat:score + points];
        [theUserScore setObject:sum forKey:@"publicScore"];
        [theUserScore saveInBackground];
    }
}

//Method that starts the transmission of the beacon
- (IBAction)startInfecting:(id)sender
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion2];
    self.beaconPeripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    [self.biteButton setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(stopInfecting) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(enableBite) userInfo:nil repeats:NO];
}

- (void)stopInfecting
{
    [self.peripheralManager stopAdvertising];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion2];
}

- (void)enableBite
{
    [self.biteButton setEnabled:YES];
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