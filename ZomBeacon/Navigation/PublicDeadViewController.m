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
	currentUser = [PFUser currentUser];
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    self.navigationItem.hidesBackButton = YES;
}

//Lets you rejoin the game for 5,000 points docked off your overall score
- (IBAction)rejoinGame
{
    [self dismissViewControllerAnimated:YES completion:nil];
    int randomNumber = [self getRandomNumberBetween:1 to:100];
    
    if (randomNumber < 20)
    {
        [self performSegueWithIdentifier:@"publicZombie" sender:self];
        [currentUser setObject:@"zombie" forKey:@"publicStatus"];
        [currentUser setObject:@"YES" forKey:@"joinedPublic"];
        [currentUser saveInBackground];
    }
    else
    {
        [self performSegueWithIdentifier:@"publicSurvivor" sender:self];
        [currentUser setObject:@"survivor" forKey:@"publicStatus"];
        [currentUser setObject:@"YES" forKey:@"joinedPublic"];
        [currentUser saveInBackground];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserScore"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    PFObject *theUserScore = [query getFirstObject];
    float score = [theUserScore[@"publicScore"] floatValue];
    float points = 3000.0f;
    NSNumber *sum = [NSNumber numberWithFloat:score - points];
    [theUserScore setObject:sum forKey:@"publicScore"];
    [theUserScore saveInBackground];
}

//Sends you back to the main menu
- (IBAction)goHome
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
