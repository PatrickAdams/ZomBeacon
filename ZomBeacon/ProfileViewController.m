//
//  ProfileViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/17/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    PFUser *user = [PFUser currentUser];
    self.userName.text = user.username;
    self.realName.text = user[@"name"];
    self.emailAddress.text = user.email;
    self.shortBio.text = user[@"bio"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
