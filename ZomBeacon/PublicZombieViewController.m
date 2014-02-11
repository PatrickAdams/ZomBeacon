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
    self.mapView.delegate = self;
    [super viewDidLoad];
    [self queryNearbyUsers];
    
    [self.infectButton addTarget:self action:@selector(startInfecting) forControlEvents:UIControlEventTouchDown];
    [self.infectButton addTarget:self action:@selector(stopInfecting) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.locationManager startUpdatingLocation];
    
    [self queryNearbyUsers];
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(queryNearbyUsers) userInfo:nil repeats:YES];
    
    //Beacon stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self initBeacon];
    
    //Zoom to user location once
    [self zoomToUserLocation:self.mapView.userLocation];
}

#pragma mark - Parse: Nearby User Querying with Custom Annotations

//Queries all nearby users and adds them to the mapView
- (void)queryNearbyUsers
{
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.mapView.userLocation.coordinate.latitude longitude:self.mapView.userLocation.coordinate.longitude];
    [[PFUser currentUser] setObject:point forKey:@"location"];
    [[PFUser currentUser] saveInBackground];
    
    if ([PFUser currentUser][@"location"])
    {
        PFGeoPoint *userGeoPoint = [PFUser currentUser][@"location"];
        PFQuery *query = [PFUser query];
        [query whereKey:@"joinedPublic" equalTo:@"YES"];
        [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:0.25];
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
                    NSString *statusOfNearbyUser = users[i][@"publicStatus"];
                    
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
        return;
    
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

//Method that initializes the device as a beacon and gives it a proximity UUID
- (void)initBeacon
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"12345678-1234-1234-1234-123456789012"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:2 minor:1 identifier:@"com.zombeacon.publicRegion"];
}

//Method that starts the transmission of the beacon
- (void)startInfecting
{
    self.beaconPeripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)stopInfecting
{
    [self.peripheralManager stopAdvertising];
}

//Method that tracks the beacon activity
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        [self.peripheralManager startAdvertising:self.beaconPeripheralData];
    }
}

#pragma mark - Closing Methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end