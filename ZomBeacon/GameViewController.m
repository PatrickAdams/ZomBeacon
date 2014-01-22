//
//  GameViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    PFUser *user = [PFUser currentUser];
    [user setObject:@"" forKey:@"status"];
    [user saveInBackground];
}

//Method that selects a random team for the user
- (IBAction)selectRandomTeam
{
    int randomNumber = [self getRandomNumberBetween:1 to:100];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if (randomNumber > 0 && randomNumber < 75 )
    {
        InfectedViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"infected"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        SurvivorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"survivor"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//Method that chooses a random number
-(int)getRandomNumberBetween:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
