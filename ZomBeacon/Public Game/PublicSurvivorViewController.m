//
//  PublicSurvivorViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 2/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "PublicSurvivorViewController.h"

@interface PublicSurvivorViewController ()

@end

@implementation PublicSurvivorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentUser = [PFUser currentUser];
    
    self.mapView.delegate = self;
    self.navigationItem.hidesBackButton = YES;
    
    locationActive = NO;
    
    [self queryNearbyUsers];
    
    //Beacon & MapView stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 1.3f;
    [self.locationManager startUpdatingLocation];
    
    //Initializing beacon region to range for zombies
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"1DC4825D-7457-474D-BE7B-B4C9B2D1C763"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.zombeacon.publicRegion"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    //Setting up beacon for sending headshots
    NSUUID *uuid2 = [[NSUUID alloc] initWithUUIDString:@"6170CEEF-4D17-4741-8068-850A601E32F0"];
    CLBeaconMajorValue major = [currentUser[@"major"] unsignedShortValue];
    CLBeaconMajorValue minor = [currentUser[@"minor"] unsignedShortValue];
    self.beaconRegion2 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid2 major:major minor:minor identifier:@"com.zombeacon.publicRegion"];
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(backHome)];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStylePlain target:self action:@selector(backHome)];
    
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
    self.queryTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(queryNearbyUsers) userInfo:nil repeats:YES];
    
    //MapView stuff
    [self zoomToUserLocation:self.mapView.userLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.queryTimer invalidate];
}

#pragma mark - Parse: Nearby User Querying with Custom Annotations

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self saveLocation];
}

- (void)saveLocation
{
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
    [currentUser setObject:point forKey:@"location"];
    [currentUser saveInBackground];
}

//Queries all nearby users and adds them to the mapView
- (void)queryNearbyUsers
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
    if (userLocation)
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
    [self zoomToUserLocation:self.mapView.userLocation];
    [UIView animateWithDuration:0.5 animations:^{self.locationButton.alpha = 0.0;}];
    [UIView animateWithDuration:0.5 animations:^{self.compassButton.alpha = 1.0;}];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [UIView animateWithDuration:0.5 animations:^{self.locationButton.alpha = 1.0;}];
    [UIView animateWithDuration:0.5 animations:^{self.compassButton.alpha = 0.0;}];
}

#pragma mark - Beacon Management

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CLBeacon *beacon = [beacons lastObject];
    
    if (beacon != nil)
    {
        [manager stopRangingBeaconsInRegion:region];
        
        if (beacon.proximity == CLProximityNear || beacon.proximity == CLProximityImmediate)
        {
            [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
            [self performSegueWithIdentifier:@"publicZombie" sender:self];
            
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"minor" equalTo:beacon.minor];
            [userQuery whereKey:@"major" equalTo:beacon.major];
            PFUser *userThatInfected = (PFUser *)[userQuery getFirstObject];
            
            //Presents the local notification
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.alertBody = [NSString stringWithFormat:@"PUBLIC GAME: You've been bitten by user: %@, you are now infected. Go find some Survivors!", userThatInfected.username];
            notification.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            
            [currentUser setObject:@"zombie" forKey:@"publicStatus"];
            [currentUser saveInBackground];
            
            //Adds 250 pts to the user's publicScore for a bite
            PFQuery *query = [PFQuery queryWithClassName:@"UserScore"];
            [query whereKey:@"user" equalTo:userThatInfected];
            PFObject *theUserScore = [query getFirstObject];
            float score = [theUserScore[@"publicScore"] floatValue];
            float points = 250.0f;
            NSNumber *sum = [NSNumber numberWithFloat:score + points];
            [theUserScore setObject:sum forKey:@"publicScore"];
            [theUserScore saveInBackground];
        }
        
    }
}

//Method that starts advertising the headshot
- (IBAction)headshotTheZombie:(id)sender
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    self.beaconPeripheralData = [self.beaconRegion2 peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    [self.headshotButton setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(stopTheHeadshot) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(enableHeadshot) userInfo:nil repeats:NO];
}

//Method that stops advertising the headshot beacon
- (void)stopTheHeadshot
{
    [self.peripheralManager stopAdvertising];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
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

#pragma mark - Closing Methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

