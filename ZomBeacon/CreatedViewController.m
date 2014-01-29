//
//  CreatedViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "CreatedViewController.h"

@interface CreatedViewController ()

@end

@implementation CreatedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //MapView stuff
    self.mapView.delegate = self;
    
    self.navigationItem.hidesBackButton = YES;
	
    self.gameNameLabel.text = self.gameNameString;
    self.createdByLabel.text = self.createdByString;
    self.dateTimeLabel.text = self.dateTimeString;
    self.inviteCodeLabel.text = self.inviteCodeString;
    self.gameLocationCoord = self.droppedPin.coordinate;
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:self.gameLocationCoord];
    [annotation setTitle:self.gameNameString]; //You can set the subtitle too
    [self.mapView addAnnotation:annotation];
    
    [self zoomToPinLocation];
}

//Method to zoom to the user location
- (void)zoomToPinLocation
{
    MKCoordinateRegion region;
    region.center = self.gameLocationCoord;
    region.span = MKCoordinateSpanMake(0.005, 0.005); //Zoom distance
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
