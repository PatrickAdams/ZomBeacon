//
//  FriendProfileViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/31/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "FriendProfileViewController.h"

@interface FriendProfileViewController ()

@end

@implementation FriendProfileViewController

- (void)viewDidLoad
{
    [self refreshImage];
    [super viewDidLoad];
    self.realName.text = self.realNameString;
    self.userName.text = self.userNameString;
    self.shortBio.text = self.shortBioString;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self refreshImage];
}

- (void)refreshImage
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query whereKey:@"user" equalTo:self.myFriend];
    
    PFFile *file = [query getFirstObject][@"imageFile"];
    self.profileImage.file = file;
    [self.profileImage loadInBackground];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
