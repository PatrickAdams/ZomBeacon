//
//  SurvivorViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 12/11/13.
//  Copyright (c) 2013 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AudioToolbox/AudioServices.h>
#import <MapKit/MapKit.h>
#import "InfectedViewController.h"

@interface SurvivorViewController : UIViewController <CLLocationManagerDelegate, CBPeripheralManagerDelegate, MKMapViewDelegate>
{
    NSTimer *timer;
}

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSDictionary *beaconPeripheralData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic, weak) IBOutlet UILabel *myCounterLabel;
@property (nonatomic, weak) IBOutlet UILabel *warningText;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (void)updateCounter:(NSTimer *)theTimer;
- (void)countdownTimer;
- (IBAction)startCounter;

@end
