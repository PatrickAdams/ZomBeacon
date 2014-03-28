//
//  BeaconManager.h
//  ZomBeacon
//
//  Created by Patrick Adams on 3/28/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@protocol BeaconManagerDelegate;

@interface BeaconManager : NSObject

@property (nonatomic, strong) NSArray *beacons;
@property (nonatomic, assign) id<BeaconManagerDelegate> delegate;

+ (id)sharedInstance;

- (void)startBeaconMonitoring;
- (void)stopBeaconMonitoring;

@end

@protocol BeaconManagerDelegate <NSObject>

- (void)beaconManager:(BeaconManager*)beaconManager didRangeBeacons:(NSArray*)beacons;

@end
