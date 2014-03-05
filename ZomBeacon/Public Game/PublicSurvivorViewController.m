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
    self.navigationItem.hidesBackButton = YES;
    
    //Beacon & MapView stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
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
    [self queryNearbyUsers];
    self.queryTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(queryNearbyUsers) userInfo:nil repeats:YES];
    self.zombieScanner = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(queryNearbyZombies) userInfo:nil repeats:YES];
    //MapView stuff
    [self.locationManager startUpdatingLocation];
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

//Will notify you when someone is within 100 feet of you if they are on the opposite team
- (void)queryNearbyZombies
{
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.mapView.userLocation.coordinate.latitude longitude:self.mapView.userLocation.coordinate.longitude];
    [currentUser setObject:point forKey:@"location"];
    [currentUser saveInBackground];
    
    if (currentUser[@"location"])
    {
        PFGeoPoint *userGeoPoint = currentUser[@"location"];
        PFQuery *query = [PFUser query];
        [query whereKey:@"joinedPublic" equalTo:@"YES"];
        [query whereKey:@"publicStatus" equalTo:@"zombie"];
        [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:0.018868];
        [query findObjectsInBackgroundWithBlock:^(NSArray *zombies, NSError *error) {
            if (!error)
            {
                //Presents the local notification
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                if (zombies.count == 1)
                {
                    notification.alertBody = [NSString stringWithFormat:@"PUBLIC GAME: There is %lu zombie very close to you. Check your map!", (unsigned long)zombies.count];
                }
                else
                {
                    notification.alertBody = [NSString stringWithFormat:@"PUBLIC GAME: There are %lu zombies very close to you. Check your map!", (unsigned long)zombies.count];
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
    if (userLocation)
    {
        MKCoordinateRegion region;
        region.center = userLocation.location.coordinate;
        region.span = MKCoordinateSpanMake(0.004, 0.004); //Zoom distance
        region = [self.mapView regionThatFits:region];
        [self.mapView setRegion:region animated:YES];
    }
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
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PublicZombieViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicZombie"];
        [self.navigationController pushViewController:vc animated:YES];
        
        //Adds 250 pts to the user's publicScore for a bite
        PFQuery *query = [PFQuery queryWithClassName:@"UserScore"];
        [query whereKey:@"user" equalTo:userThatInfected];
        PFObject *theUserScore = [query getFirstObject];
        float score = [theUserScore[@"publicScore"] floatValue];
        float points = 250.0f;
        NSNumber *sum = [NSNumber numberWithFloat:score + points];
        [theUserScore setObject:sum forKey:@"publicScore"];
        [theUserScore saveInBackground];
        
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
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
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(enableHeadshot) userInfo:nil repeats:NO];
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

