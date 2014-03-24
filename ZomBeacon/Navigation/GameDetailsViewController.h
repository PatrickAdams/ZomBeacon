//
//  JoinedViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "PrivateLobbyViewController.h"

@interface GameDetailsViewController : UIViewController <MKMapViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
{
    PFUser *currentUser;
}

@property (nonatomic, weak) IBOutlet UILabel *gameHostLabel;
@property (nonatomic, weak) IBOutlet UILabel *gameDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *gameNameLabel;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSString *gameHostString;
@property (nonatomic, strong) NSString *gameDateString;
@property (nonatomic, strong) NSString *gameNameString;
@property (nonatomic, strong) NSString *gameIdString;
@property (nonatomic, strong) NSString *gameAddressString;
@property (nonatomic, readwrite) CLLocationCoordinate2D gameLocationCoord;
@property (nonatomic, readwrite) double gameLocationLat;
@property (nonatomic, readwrite) double gameLocationLong;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) MKPlacemark *placemark;
@property (nonatomic, weak) IBOutlet UIView *shareView;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumRegularFonts;

- (IBAction)openInMaps;
- (IBAction)joinGame;

- (IBAction)shareViaEmail;
- (IBAction)shareViaTwitter;
- (IBAction)shareViaFacebook;
- (IBAction)shareViaSMS;
- (IBAction)inviteFriends;


@end
