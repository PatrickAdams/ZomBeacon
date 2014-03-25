//
//  PrivateSurvivorViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 12/11/13.
//  Copyright (c) 2013 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <MapKit/MapKit.h>
#import "PrivateZombieViewController.h"
#import <Parse/Parse.h>
#import "UserAnnotations.h"
#import "ProfileViewController.h"

@interface PrivateSurvivorViewController : UIViewController <CLLocationManagerDelegate, CBPeripheralManagerDelegate, MKMapViewDelegate>
{
    NSTimer *timer;
    PFUser *currentUser;
}

@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion2;
@property (nonatomic, strong) NSDictionary *beaconPeripheralData;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSTimer *queryTimer;
@property (nonatomic, strong) NSTimer *shieldTimer;
@property (nonatomic, weak) IBOutlet UILabel *survivorCount;
@property (nonatomic, weak) IBOutlet UILabel *zombieCount;
@property (nonatomic, weak) IBOutlet UIButton *headshotButton;
@property (nonatomic, weak) IBOutlet UIButton *locationButton;
@property (nonatomic, weak) IBOutlet UIButton *compassButton;
@property (nonatomic, strong) NSString *gameIdString;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumRegularFonts;

- (IBAction)trackMyOrientation;
- (IBAction)centerMapOnLocation;
- (IBAction)headshotTheZombie:(id)sender;

@end
