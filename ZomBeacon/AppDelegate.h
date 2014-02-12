//
//  AppDelegate.h
//  ZomBeacon
//
//  Created by Patrick Adams on 12/11/13.
//  Copyright (c) 2013 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TestFlight.h"
#import <ProximityKit/ProximityKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "PublicZombieViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, PKManagerDelegate, CBCentralManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property PKManager *proximityKitManager;
@property (nonatomic, strong) CBCentralManager *centralManager;

@end
