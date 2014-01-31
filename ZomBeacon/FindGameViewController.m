//
//  FindGameViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "FindGameViewController.h"

@interface FindGameViewController ()

@end

@implementation FindGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (IBAction)findGame
{
    PFQuery *query = [PFQuery queryWithClassName:@"PrivateGames"];
    [query whereKey:@"objectId" equalTo:self.findGameField.text];
    [query includeKey:@"hostUser"];
    NSArray *privateGames = [query findObjects];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GameDetailsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"gamedetails"];
    
    for (int i = 0; i < privateGames.count; i++)
    {
        PFObject *privateGame = [privateGames objectAtIndex:0];
        vc.dateTimeLabelString = privateGame[@"dateTime"];
        vc.gameNameLabelString = privateGame[@"gameName"];
        PFGeoPoint *gameLocation = privateGame[@"location"];
        CLLocationCoordinate2D gameLocationCoords = CLLocationCoordinate2DMake(gameLocation.latitude, gameLocation.longitude);
        vc.gameLocationCoord = gameLocationCoords;
        vc.gameIDString = privateGame.objectId;
        
        PFObject *hostUser = privateGame[@"hostUser"];
        vc.hostUserLabelString = hostUser[@"name"];
    }
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
