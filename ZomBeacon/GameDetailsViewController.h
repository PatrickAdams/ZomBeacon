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
#import "LobbyViewController.h"

@interface GameDetailsViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *hostUserLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *gameNameLabel;
@property (nonatomic, strong) NSString *hostUserLabelString;
@property (nonatomic, strong) NSString *dateTimeLabelString;
@property (nonatomic, strong) NSString *gameNameLabelString;
@property (nonatomic, strong) NSString *gameIDString;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, readwrite) CLLocationCoordinate2D gameLocationCoord;
@property (nonatomic, readwrite) double gameLocationLat;
@property (nonatomic, readwrite) double gameLocationLong;

- (IBAction)openInMaps;
- (IBAction)joinGame;


@end
