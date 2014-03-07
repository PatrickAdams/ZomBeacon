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

@interface PublicSurvivorViewController : UIViewController <CLLocationManagerDelegate, CBPeripheralManagerDelegate, MKMapViewDelegate>
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
@property (nonatomic, weak) IBOutlet UIButton *headshotButton;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumRegularFonts;

- (IBAction)trackMyOrientation;
- (IBAction)centerMapOnLocation;
- (IBAction)headshotTheZombie:(id)sender;

@end
