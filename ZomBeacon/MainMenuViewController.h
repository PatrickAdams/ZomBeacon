//
//  MainMenuViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PublicLobbyViewController.h"
#import "MBProgressHUD.h"
#import "LoginViewController.h"

@interface MainMenuViewController : UIViewController


@property (nonatomic, strong) PFUser *currentUser;

- (IBAction)startPublicGame;

@end
