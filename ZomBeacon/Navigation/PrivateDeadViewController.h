//
//  PrivateDeadViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 2/24/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMenuViewController.h"

@interface PrivateDeadViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
{
    PFUser *currentUser;
}

@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumRegularFonts;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSTimer *queryTimer;
@property (nonatomic, weak) IBOutlet UILabel *survivorCount;
@property (nonatomic, weak) IBOutlet UILabel *zombieCount;
@property (nonatomic, strong) NSString *gameIdString;
@property (nonatomic, weak) IBOutlet UIButton *locationButton;
@property (nonatomic, weak) IBOutlet UIButton *compassButton;

- (IBAction)trackMyOrientation;
- (IBAction)centerMapOnLocation;

@end
