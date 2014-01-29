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

@interface CreatedViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, weak) NSString *gameNameString;
@property (nonatomic, weak) NSString *createdByString;
@property (nonatomic, weak) NSString *dateTimeString;
@property (nonatomic, weak) NSString *inviteCodeString;
@property (nonatomic, weak) NSString *locationLatitudeString;
@property (nonatomic, weak) NSString *locationLongitudeString;
@property (nonatomic, weak) IBOutlet UILabel *gameNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *createdByLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *inviteCodeLabel;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) UserAnnotations *droppedPin;
@property (nonatomic, readwrite) CLLocationCoordinate2D gameLocationCoord;


@end
