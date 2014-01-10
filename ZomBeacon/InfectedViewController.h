//
//  InfectedViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 12/11/13.
//  Copyright (c) 2013 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <MapKit/MapKit.h>

@interface InfectedViewController : UIViewController <CLLocationManagerDelegate, CBPeripheralManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSDictionary *beaconPeripheralData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, weak) IBOutlet UILabel *infectedLabel;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@end
