//
//  ProfileViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/17/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

@interface ProfileViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *userName;
@property (nonatomic, weak) IBOutlet UILabel *realName;
@property (nonatomic, weak) IBOutlet UILabel *emailAddress;
@property (nonatomic, weak) IBOutlet UILabel *shortBio;
@property (nonatomic, weak) IBOutlet UIImageView *profileImage;

@end
