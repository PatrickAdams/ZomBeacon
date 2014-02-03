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

@interface CreatedViewController : UIViewController <MKMapViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSString *gameNameString;
@property (nonatomic, strong) NSString *createdByString;
@property (nonatomic, strong) NSString *dateTimeString;
@property (nonatomic, strong) NSString *inviteCodeString;
@property (nonatomic, strong) NSString *locationLatitudeString;
@property (nonatomic, strong) NSString *locationLongitudeString;
@property (nonatomic, weak) IBOutlet UILabel *gameNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *createdByLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *inviteCodeLabel;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) UserAnnotations *droppedPin;
@property (nonatomic, readwrite) CLLocationCoordinate2D gameLocationCoord;

- (IBAction)shareWithFriends;


@end
