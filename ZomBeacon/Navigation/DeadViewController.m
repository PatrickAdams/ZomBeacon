//
//  DeadViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 2/24/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "DeadViewController.h"

@interface DeadViewController ()

@end

@implementation DeadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (IBAction)rejoinGame
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainMenuViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainmenu"];
    [self.navigationController pushViewController:vc animated:YES];

    PFQuery *query = [PFQuery queryWithClassName:@"UserScore"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    PFObject *theUserScore = [query getFirstObject];
    float score = [theUserScore[@"score"] floatValue];
    float points = 5000.0f;
    NSNumber *sum = [NSNumber numberWithFloat:score - points];
    [theUserScore setObject:sum forKey:@"score"];
    [theUserScore saveInBackground];
    
    [[PFUser currentUser] setObject:@"" forKey:@"publicStatus"];
    [[PFUser currentUser] saveInBackground];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
