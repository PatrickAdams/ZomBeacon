//
//  BeaconManager.m
//  ZomBeacon
//
//  Created by Patrick Adams on 3/28/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "BeaconManager.h"
#import "AppDelegate.h"

@interface BeaconManager()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

@end

@implementation BeaconManager

+ (id)sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id sharedBeaconManager = nil;
    dispatch_once(&pred, ^{
        sharedBeaconManager = [[self alloc] init];
    });
    return sharedBeaconManager;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    return self;
}

- (void)startBeaconMonitoring:(NSString*)forUUID
{
    NSString * uuidString = forUUID;
    NSUUID * uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.zombeacon.publicRegion"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)stopBeaconMonitoring
{
    //Stop the region monitoring
    if(self.locationManager != nil && self.beaconRegion != nil) {
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    self.beacons = beacons;
    if(self.delegate != nil) {
        [self.delegate beaconManager:self didRangeBeacons:self.beacons];
    }
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicSurvivor"];
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate.window.rootViewController.navigationController pushViewController:vc animated:YES];
}

@end
