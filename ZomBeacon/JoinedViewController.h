//
//  JoinedViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface JoinedViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *hostUserLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *gameNameLabel;
@property (nonatomic, weak) NSString *hostUserLabelString;
@property (nonatomic, weak) NSString *dateTimeLabelString;
@property (nonatomic, weak) NSString *gameNameLabelString;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, readwrite) CLLocationCoordinate2D gameLocationCoord;
@property (nonatomic, readwrite) double gameLocationLat;
@property (nonatomic, readwrite) double gameLocationLong;

- (IBAction)openInMaps;


@end
