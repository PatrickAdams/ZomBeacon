//
//  PublicSurvivorViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 2/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <MapKit/MapKit.h>
#import "PublicZombieViewController.h"
#import <Parse/Parse.h>
#import "UserAnnotations.h"
#import "ProfileViewController.h"
#import "BeaconManager.h"

@interface PublicSurvivorViewController : UIViewController <CLLocationManagerDelegate, CBPeripheralManagerDelegate, MKMapViewDelegate>
{
    NSTimer *timer;
    PFUser *currentUser;
    BOOL mapKeyShowing;
}

@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion2;
@property (nonatomic, strong) NSDictionary *beaconPeripheralData;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSTimer *queryTimer;
@property (nonatomic, weak) IBOutlet UIButton *headshotButton;
@property (nonatomic, weak) IBOutlet UIButton *locationButton;
@property (nonatomic, weak) IBOutlet UIButton *compassButton;
@property (nonatomic, weak) IBOutlet UIView *mapKeyView;
@property (nonatomic, strong) NSMutableArray *foundBeacons;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumRegularFonts;
@property (nonatomic, strong) BeaconManager *beaconManager;

- (IBAction)trackMyOrientation;
- (IBAction)centerMapOnLocation;
- (IBAction)headshotTheZombie:(id)sender;
- (IBAction)showMapKey;
- (void)rangedBeacons:(NSNotification *)notification;

@end
