//
//  GameDetailsViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "GameDetailsViewController.h"

@interface GameDetailsViewController ()

@end

@implementation GameDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.gameDateLabel.text = self.gameDateString;
    self.gameHostLabel.text = self.gameHostString;
    self.gameNameLabel.text = self.gameNameString;
    
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

- (IBAction)openInMaps
{
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        CLLocationCoordinate2D coordinate = self.gameLocationCoord;
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:[NSString stringWithFormat:@"ZomBeacon: %@", self.gameNameString]];
        // Pass the map item to the Maps app
        [mapItem openInMapsWithLaunchOptions:nil];
    }
}

- (IBAction)joinGame
{
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"currentGame"] = self.gameIdString;
    [currentUser save];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PrivateLobbyViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"privateLobby"];

    [self.navigationController pushViewController:vc animated:YES];
    
    vc.gameNameString = self.gameNameString;
    vc.gameDateString = self.gameDateString;
    vc.gameHostString = self.gameHostString;
    vc.gameIdString = self.gameIdString;
    vc.gameLocationCoord = self.gameLocationCoord;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
