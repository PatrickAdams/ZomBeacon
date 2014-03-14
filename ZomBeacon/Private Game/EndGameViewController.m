//
//  EndGameViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 3/12/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "EndGameViewController.h"

@interface EndGameViewController ()

@end

@implementation EndGameViewController

- (void)viewDidLoad
{
    self.navigationItem.hidesBackButton = YES;
    
    PFQuery *countsQuery = [PFQuery queryWithClassName:@"PrivateGames"];
    [countsQuery whereKey:@"objectId" equalTo:[PFUser currentUser][@"currentGame"]];
    PFObject *currentGame = [countsQuery getFirstObject];
    NSNumber *zombieCount = currentGame[@"zombieCount"];
    NSNumber *survivorCount = currentGame[@"survivorCount"];
    
    if ([zombieCount intValue] > [survivorCount intValue])
    {
        self.winnerLabel.text = @"Zombies Win!!";
    }
    else
    {
        self.winnerLabel.text = @"Survivors Win!!";
    }
    
    [super viewDidLoad];
	
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
}

- (IBAction)goHome
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
