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
    currentUser = [PFUser currentUser];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationItem.hidesBackButton = YES;
    [currentUser setObject:@"" forKey:@"status"];
    [currentUser setObject:@"" forKey:@"currentGame"];
    [currentUser saveInBackground];
}

- (IBAction)startPublicGame
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PublicLobbyViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicLobby"];
    [self.navigationController pushViewController:vc animated:YES];
    
    [currentUser setObject:@"YES" forKey:@"joinedPublic"];
    [currentUser save];
}

//Method that logs the user out with the Parse framework
- (IBAction)logUserOut
{
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
