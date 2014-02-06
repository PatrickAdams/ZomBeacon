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

@interface MainMenuViewController : UIViewController
{
    PFUser *currentUser;
}

- (IBAction)logUserOut;
- (IBAction)startPublicGame;

@end
