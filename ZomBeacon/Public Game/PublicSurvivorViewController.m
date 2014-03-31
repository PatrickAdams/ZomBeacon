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
    
    mapKeyShowing = NO;
    
    [self queryNearbyUsers];
    
    //Beacon & MapView stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.beaconManager = [BeaconManager sharedManager];
    
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
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStylePlain target:self action:@selector(backHome)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    //NSNotificationCenter
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(invalidateTimer) name: @"didEnterBackground" object: nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"isSurvivor" object:nil userInfo:nil];
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
    self.queryTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(queryNearbyUsers) userInfo:nil repeats:YES];
    
    //MapView stuff
    [self zoomToUserLocation:self.mapView.userLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self invalidateTimer];
}

- (void)invalidateTimer
{
    [self.queryTimer invalidate];
}

#pragma mark - Parse: Nearby User Querying with Custom Annotations

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

//Method that starts advertising the headshot
- (IBAction)headshotTheZombie:(id)sender
{
    [self.beaconManager stopBeaconMonitoring];
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
    [self.beaconManager startBeaconMonitoring:@"1DC4825D-7457-474D-BE7B-B4C9B2D1C763"];
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

