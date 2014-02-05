//
//  EditProfileViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 2/5/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "EditProfileViewController.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	currentUser = [PFUser currentUser];
    self.nameField.text = currentUser[@"name"];
    self.usernameField.text = currentUser.username;
    self.passwordField.text = currentUser.password;
    self.emailField.text = currentUser.email;
    self.bioField.text = currentUser[@"bio"];
}

- (IBAction)saveProfileChanges
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
