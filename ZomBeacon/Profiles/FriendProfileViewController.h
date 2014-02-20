//
//  FriendProfileViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/31/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendProfileViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *userName;
@property (nonatomic, weak) IBOutlet UILabel *realName;
@property (nonatomic, weak) IBOutlet UILabel *shortBio;
@property (nonatomic, weak) IBOutlet PFImageView *profileImage;
@property (nonatomic, strong) NSString *userNameString;
@property (nonatomic, strong) NSString *realNameString;
@property (nonatomic, strong) NSString *shortBioString;
@property (nonatomic, strong) NSString *currentGameString;
@property (nonatomic, strong) PFUser *myFriend;

- (void)refreshImage;

@end
