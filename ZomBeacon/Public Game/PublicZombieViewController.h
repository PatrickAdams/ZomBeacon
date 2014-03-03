//
//  PublicZombieViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 2/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "UserAnnotations.h"
#import "PublicDeadViewController.h"
#import <ProximityKit/ProximityKit.h>

@interface PublicZombieViewController : UIViewController <CLLocationManagerDelegate, CBPeripheralManagerDelegate, MKMapViewDelegate, PKManagerDelegate>
{
    PFUser *currentUser;
}

@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion2;
@property (nonatomic, strong) NSDictionary *beaconPeripheralData;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSTimer *queryTimer;
@property (nonatomic, weak) IBOutlet UIButton *biteButton;
@property PKManager *proximityKitManager;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;

- (IBAction)trackMyOrientation;
- (IBAction)centerMapOnLocation;
- (IBAction)startInfecting:(id)sender;

@end
