//
//  JoinViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "JoinViewController.h"

@interface JoinViewController ()

@end

@implementation JoinViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (IBAction)joinGame
{
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"currentGame"] = self.joinGameField.text;
    [currentUser saveInBackground];
    
    PFQuery *query = [PFQuery queryWithClassName:@"PrivateGames"];
    [query whereKey:@"objectId" equalTo:self.joinGameField.text];
    NSArray *privateGames = [query findObjects];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    JoinedViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"joined"];
    
    for (int i = 0; i < privateGames.count; i++)
    {
        PFObject *privateGame = [privateGames objectAtIndex:0];
        vc.dateTimeLabelString = privateGame[@"dateTime"];
        vc.locationLabelString = privateGame[@"location"];
    }
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
