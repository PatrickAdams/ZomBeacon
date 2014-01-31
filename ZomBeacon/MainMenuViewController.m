//
//  MainMenuViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.currentUser = [PFUser currentUser];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.currentUser setObject:@"" forKey:@"status"];
    [self.currentUser setObject:[NSNull null] forKey:@"location"];
    [self.currentUser saveInBackground];
}

- (IBAction)startPublicGame
{
    [self.currentUser setObject:@"" forKey:@"currentGame"];
    [self.currentUser saveInBackground];
}

//Method that logs the user out with the Parse framework
- (IBAction)logUserOut
{
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
