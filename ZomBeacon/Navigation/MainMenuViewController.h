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

@interface MainMenuViewController : UIViewController <CLLocationManagerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
{
    PFUser *currentUser;
}

@property (nonatomic, strong) PFGeoPoint *point;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) IBOutlet UIButton *startPublicGameButton;
@property (nonatomic, weak) IBOutlet UIButton *createPrivateGameButton;
@property (nonatomic, weak) IBOutlet UIButton *startPrivateGameButton;

- (IBAction)startPublicGame;

@end
