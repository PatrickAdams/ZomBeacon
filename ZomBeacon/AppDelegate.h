//
//  AppDelegate.h
//  ZomBeacon
//
//  Created by Patrick Adams on 12/11/13.
//  Copyright (c) 2013 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ProximityKit/ProximityKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "PublicZombieViewController.h"
#import "FindGameViewController.h"
#import "MainMenuViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CBCentralManagerDelegate, CLLocationManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBPeripheral *thePeripheral;
@property (nonatomic, strong) CBMutableCharacteristic *peripheralCharacteristic;
@property (nonatomic, strong) CBMutableService *peripheralService;
@property (nonatomic, strong) PFGeoPoint *point;
@property (nonatomic, strong) NSTimer *locationTimer;
@property (nonatomic, strong) NSTimer *queryEnemiesTimer;
@property (nonatomic, strong) NSMutableArray *peripheralsArray;

@end
