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

- (void)viewDidAppear:(BOOL)animated {
    self.navigationItem.hidesBackButton = YES;
    [currentUser setObject:@"" forKey:@"status"];
    [currentUser setObject:@"" forKey:@"currentGame"];
    [currentUser setObject:[NSNull null] forKey:@"location"];
    [currentUser saveInBackground];
}

- (IBAction)startPublicGame
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LobbyViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"gamelobby"];
    [self.navigationController pushViewController:vc animated:YES];
    
    [currentUser setObject:@"public" forKey:@"currentGame"];
    [currentUser save];
    
    vc.gameNameString = @"Public Game";
    vc.gameDateString = @"Unlimited";
    vc.gameHostString = @"The Godfather";
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
