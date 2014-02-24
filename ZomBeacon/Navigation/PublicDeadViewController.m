//
//  PublicDeadViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 2/24/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "PublicDeadViewController.h"

@interface PublicDeadViewController ()

@end

@implementation PublicDeadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.currentUser = [PFUser currentUser];
}

- (IBAction)rejoinGame
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    int randomNumber = [self getRandomNumberBetween:1 to:100];
    
    if (randomNumber < 20)
    {
        PublicZombieViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicZombie"];
        [self.navigationController pushViewController:vc animated:YES];
        [self.currentUser setObject:@"zombie" forKey:@"publicStatus"];
        [self.currentUser setObject:@"YES" forKey:@"joinedPublic"];
        [self.currentUser saveInBackground];
    }
    else
    {
        PublicSurvivorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicSurvivor"];
        [self.navigationController pushViewController:vc animated:YES];
        [self.currentUser setObject:@"survivor" forKey:@"publicStatus"];
        [self.currentUser setObject:@"YES" forKey:@"joinedPublic"];
        [self.currentUser saveInBackground];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserScore"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    PFObject *theUserScore = [query getFirstObject];
    float score = [theUserScore[@"score"] floatValue];
    float points = 5000.0f;
    NSNumber *sum = [NSNumber numberWithFloat:score - points];
    [theUserScore setObject:sum forKey:@"score"];
    [theUserScore saveInBackground];
}

- (IBAction)goHome
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainMenuViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainmenu"];
    vc.navigationItem.hidesBackButton = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

//Method that chooses a random number
-(int)getRandomNumberBetween:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
