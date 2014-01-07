//
//  SurvivorViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 12/11/13.
//  Copyright (c) 2013 Patrick Adams. All rights reserved.
//

#import "SurvivorViewController.h"
#import "InfectedViewController.h"

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
	self.warningText.alpha = 0.0f;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self initRegion];
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
}

- (IBAction)startCounter
{
    secondsLeft = 600;
    [self countdownTimer];
}

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

- (void)countdownTimer
{
    secondsLeft = minutes = seconds = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

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
        self.warningText.alpha = 1.0f;
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    else
    {
        self.warningText.alpha = 0.0f;
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
        [self presentViewController:vc animated:YES completion:nil];
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
