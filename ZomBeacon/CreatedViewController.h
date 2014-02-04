//
//  CreatedViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UserAnnotations.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <Social/Social.h>

@interface CreatedViewController : UIViewController <MKMapViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSString *gameNameString;
@property (nonatomic, strong) NSString *gameHostString;
@property (nonatomic, strong) NSString *gameDateString;
@property (nonatomic, strong) NSString *gameIdString;
@property (nonatomic, strong) NSString *locationLatitudeString;
@property (nonatomic, strong) NSString *locationLongitudeString;
@property (nonatomic, strong) NSString *gameAddressString;
@property (nonatomic, weak) IBOutlet UILabel *gameNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *gameHostLabel;
@property (nonatomic, weak) IBOutlet UILabel *gameDateLabel;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) UserAnnotations *droppedPin;
@property (nonatomic, readwrite) CLLocationCoordinate2D gameLocationCoord;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) MKPlacemark *placemark;

- (IBAction)shareViaEmail;
- (IBAction)shareViaTwitter;
- (IBAction)shareViaFacebook;


@end
