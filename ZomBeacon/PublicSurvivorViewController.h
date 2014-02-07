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
#import <AudioToolbox/AudioServices.h>
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

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSDictionary *beaconPeripheralData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic, weak) IBOutlet UILabel *myCounterLabel;
@property (nonatomic, weak) IBOutlet UILabel *warningText;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSString *userName;

- (void)updateCounter:(NSTimer *)theTimer;
- (void)countdownTimer;
- (IBAction)startCounter;
- (IBAction)trackMyOrientation;
- (IBAction)centerMapOnLocation;

@end
