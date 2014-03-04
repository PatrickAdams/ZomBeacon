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
    
    if (self.inviteCodeFromURL != nil)
    {
        self.findGameField.text = self.inviteCodeFromURL;
    }
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
}

- (IBAction)findGame
{
    PFQuery *query = [PFQuery queryWithClassName:@"PrivateGames"];
    [query whereKey:@"objectId" equalTo:self.findGameField.text];
    [query includeKey:@"hostUser"];
    NSArray *privateGames = [query findObjects];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GameDetailsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"gamedetails"];
    
    if (privateGames.count > 0)
    {
        for (int i = 0; i < privateGames.count; i++)
        {
            PFObject *privateGame = [privateGames objectAtIndex:0];
            vc.gameDateString = privateGame[@"dateTime"];
            vc.gameNameString = privateGame[@"gameName"];
            PFGeoPoint *gameLocation = privateGame[@"location"];
            CLLocationCoordinate2D gameLocationCoords = CLLocationCoordinate2DMake(gameLocation.latitude, gameLocation.longitude);
            vc.gameLocationCoord = gameLocationCoords;
            vc.gameIdString = privateGame.objectId;
            
            PFObject *hostUser = privateGame[@"hostUser"];
            vc.gameHostString = hostUser[@"name"];
        }
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Games Found" message:@"No games were found that match your code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
