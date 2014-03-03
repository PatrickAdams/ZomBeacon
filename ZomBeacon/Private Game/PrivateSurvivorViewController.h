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

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion2;
@property (nonatomic, strong) NSDictionary *beaconPeripheralData;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, weak) IBOutlet UILabel *myCounterLabel;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSTimer *queryTimer;
@property (nonatomic, strong) NSTimer *shieldTimer;
@property (nonatomic, weak) IBOutlet UILabel *survivorCount;
@property (nonatomic, weak) IBOutlet UILabel *zombieCount;
@property (nonatomic, weak) IBOutlet UIButton *headshotButton;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumRegularFonts;

- (void)updateCounter:(NSTimer *)theTimer;
- (void)countdownTimer;
- (IBAction)startCounter;
- (IBAction)trackMyOrientation;
- (IBAction)centerMapOnLocation;
- (IBAction)headshotTheZombie:(id)sender;

@end
