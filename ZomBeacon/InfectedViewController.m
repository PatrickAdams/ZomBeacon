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
}

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
    mapRegion.span.latitudeDelta = 0.005;
    mapRegion.span.longitudeDelta = 0.005;
    
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

