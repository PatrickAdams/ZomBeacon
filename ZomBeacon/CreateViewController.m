//
//  CreateViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "CreateViewController.h"

@interface CreateViewController ()

@end

@implementation CreateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (IBAction)createNewGame
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CreatedViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"createdview"];
    
    PFUser *user = [PFUser currentUser];
    PFObject *privateGame = [PFObject objectWithClassName:@"PrivateGames"];
    privateGame[@"gameName"] = self.gameNameTextField.text;
    privateGame[@"hostUser"] = user;
    privateGame[@"dateTime"] = self.dateTimeTextField.text;
    privateGame[@"location"] = self.locationTextField.text;
    [privateGame save];
    
    vc.gameNameString = privateGame[@"gameName"];
    vc.createdByString = user.username;
    vc.dateTimeString = privateGame[@"dateTime"];
    vc.locationString = privateGame[@"location"];
    vc.inviteCodeString = privateGame.objectId;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
