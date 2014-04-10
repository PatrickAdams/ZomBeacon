//
//  AppDelegate.h
//  ZomBeacon
//
//  Created by Patrick Adams on 12/11/13.
//  Copyright (c) 2013 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "PublicZombieViewController.h"
#import "FindGameViewController.h"
#import "MainMenuViewController.h"
#import "BeaconManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CBCentralManagerDelegate, CLLocationManagerDelegate, BeaconManagerDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) PFGeoPoint *point;
@property (nonatomic, strong) NSString *gameIdString;
@property (nonatomic, strong) NSTimer *didRangeBeaconsTimer;

@end
