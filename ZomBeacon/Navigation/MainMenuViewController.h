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

@interface MainMenuViewController : UIViewController <CLLocationManagerDelegate, UIAlertViewDelegate>
{
    PFUser *currentUser;
}

@property (nonatomic, strong) PFGeoPoint *point;
@property (nonatomic, strong) NSTimer *locationTimer;
@property (nonatomic, weak) IBOutlet UIButton *startPublicGameButton;
@property (nonatomic, weak) IBOutlet UIButton *createPrivateGameButton;
@property (nonatomic, weak) IBOutlet UIButton *findPrivateGameButton;

@property (nonatomic, strong) CLLocationManager *locationManager;

- (IBAction)startPublicGame;
//- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

@end
