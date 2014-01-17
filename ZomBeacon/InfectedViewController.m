//
//  InfectedViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 12/11/13.
//  Copyright (c) 2013 Patrick Adams. All rights reserved.
//

#import "InfectedViewController.h"

@interface InfectedViewController ()

@end

@implementation InfectedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //MapView stuff
    self.mapView.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    //Beacon stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self initBeacon];
    [self transmitBeacon];
    
    //Parse stuff
    [self queryNearbyUsers];
}

- (void)viewDidAppear:(BOOL)animated {
    
    PFUser *user = [PFUser currentUser];
    [user setObject:@"zombie" forKey:@"status"];
    [user saveInBackground];
    
    [self queryNearbyUsers];
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(queryNearbyUsers) userInfo:nil repeats:YES];
    
    //Zoom to user location once
    [self zoomToUserLocation:self.mapView.userLocation];
}

#pragma mark - Parse: Nearby User Querying with Custom Annotations

//Queries all nearby users and adds them to the mapView
- (void)queryNearbyUsers
{
    PFUser *user = [PFUser currentUser];
    
    if (user[@"location"])
    {
        PFGeoPoint *userGeoPoint = user[@"location"];
        PFQuery *query = [PFUser query];
        query.limit = 30;
        [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:0.05];
        NSArray *nearbyUsers = [query findObjects];
        
        for (int i = 0; i < nearbyUsers.count ; i++)
        {
            PFGeoPoint *geoPointsForNearbyUsers = nearbyUsers[i][@"location"];
            NSString *nameOfNearbyUsers = nearbyUsers[i][@"name"];
            NSString *statusOfNearbyUsers = nearbyUsers[i][@"status"];

            // Set some coordinates for our position
            CLLocationCoordinate2D location;
            location.latitude = (double) geoPointsForNearbyUsers.latitude;
            location.longitude = (double) geoPointsForNearbyUsers.longitude;
            
            // First remove all annotations to refresh the status of them
            UserAnnotations *newAnnotation;
            [self.mapView removeAnnotations:self.mapView.annotations];
            
            if ([statusOfNearbyUsers isEqualToString:@"survivor"])
            {
                newAnnotation = [[UserAnnotations alloc] initWithTitle:nameOfNearbyUsers andCoordinate:location andImage:[UIImage imageNamed:@"blue"]];
            }
            else if ([statusOfNearbyUsers isEqualToString:@"zombie"])
            {
                newAnnotation = [[UserAnnotations alloc] initWithTitle:nameOfNearbyUsers andCoordinate:location andImage:[UIImage imageNamed:@"red"]];
            }
            
            [self.mapView addAnnotation:newAnnotation];
        }
    }
    else
    {
        NSLog(@"No location found reload");
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
    region.span = MKCoordinateSpanMake(0.005, 0.005); //Zoom distance
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - Beacon Management

//Method that initializes the device as a beacon and gives it a proximity UUID
- (void)initBeacon
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"12345678-1234-1234-1234-123456789012"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:1 minor:1 identifier:@"com.patrickadams.theRegion"];
}

//Method that starts the transmission of the beacon
- (void)transmitBeacon
{
    self.beaconPeripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
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

//Tells the peripheral manager to stop looking for beacons when the view dissapears
- (void)viewWillDisappear:(BOOL)animated
{
    [self.peripheralManager stopAdvertising];
}

@end

