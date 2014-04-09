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
    static BeaconManager *sharedBeaconManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
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
    NSUUID * uuid = [[NSUUID alloc] initWithUUIDString:forUUID];
    
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
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    if(self.delegate != nil) {
        [self.delegate beaconManager:self didFailToRangeBeacons:error];
    }
}

@end
