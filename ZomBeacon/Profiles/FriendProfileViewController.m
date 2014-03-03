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
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height /2;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderWidth = 0;
    
    [self refreshImage];
    [super viewDidLoad];
    self.realName.text = self.realNameString;
    self.userName.text = self.userNameString;
    self.shortBio.text = self.shortBioString;
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
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
