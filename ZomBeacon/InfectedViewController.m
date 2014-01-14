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
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];

    [super viewDidLoad];
    [self initBeacon];
    [self transmitBeacon];
    
    PFUser *user = [PFUser currentUser];
    
    [user setObject:@"zombie" forKey:@"status"];
    [user saveInBackground];
    
    [self queryNearbyUsers];
    
    [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(queryNearbyUsers) userInfo:nil repeats:YES];
}

#pragma mark - Parse: Nearby User Querying with Custom Annotations

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
        
        UserAnnotations *newAnnotation;
        [self.mapView removeAnnotation:newAnnotation];
        
        for (int i = 0; i < nearbyUsers.count ; i++)
        {
            PFGeoPoint *geoPointsForNearbyUsers = nearbyUsers[i][@"location"];
            NSString *nameOfNearbyUsers = nearbyUsers[i][@"name"];
            NSString *statusOfNearbyUsers = nearbyUsers[i][@"status"];
            NSLog(@"Username: %@, Latitude: %f, Longitude: %f", nameOfNearbyUsers, geoPointsForNearbyUsers.latitude, geoPointsForNearbyUsers.longitude);
            
            // Set some coordinates for our position
            CLLocationCoordinate2D location;
            location.latitude = (double) geoPointsForNearbyUsers.latitude;
            location.longitude = (double) geoPointsForNearbyUsers.longitude;
            
            // Add the annotation to our map view
            
            if ([statusOfNearbyUsers isEqualToString:@"survivor"])
            {
                newAnnotation = [[UserAnnotations alloc] initWithTitle:nameOfNearbyUsers andCoordinate:location andImage:[UIImage imageNamed:@"good"]];
            }
            else
            {
                newAnnotation = [[UserAnnotations alloc] initWithTitle:nameOfNearbyUsers andCoordinate:location andImage:[UIImage imageNamed:@"bad"]];
            }
            
            [self.mapView addAnnotation:newAnnotation];
        }
    }
    else
    {
        NSLog(@"No location found reload");
    }
}

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

#pragma mark - Location and Beacon Management

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

//Method that tracks user location changes
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    MKCoordinateRegion mapRegion;
    mapRegion.center = newLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.002;
    mapRegion.span.longitudeDelta = 0.002;
    
    [self.mapView setRegion:mapRegion animated:YES];
}
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

