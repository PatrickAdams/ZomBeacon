//
//  PrivateLobbyViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 2/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FriendProfileViewController.h"
#import "UserLobbyCell.h"
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MapKit/MapKit.h>
#import <Social/Social.h>
#import "PrivateZombieViewController.h"
#import "PrivateSurvivorViewController.h"

@interface PrivateLobbyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,MFMailComposeViewControllerDelegate, MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
    PFUser *currentUser;
    int minutes, seconds;
    int secondsLeft;
    NSTimer *timer;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *gameNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *gameDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *gameHostLabel;
@property (nonatomic, weak) IBOutlet UIButton *assignTeamsButton;
@property (nonatomic, weak) IBOutlet UIButton *startGameButton;
@property (nonatomic, weak) IBOutlet UIButton *openInMapsButton;
@property (nonatomic, strong) NSString *gameNameString;
@property (nonatomic, strong) NSString *gameDateString;
@property (nonatomic, strong) NSString *gameHostString;
@property (nonatomic, strong) NSString *gameIdString;
@property (nonatomic, strong) NSString *gameAddressString;
@property (nonatomic, readwrite) CLLocationCoordinate2D gameLocationCoord;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) MKPlacemark *placemark;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *customFont;


- (NSArray *)getPlayersInCurrentGame;
- (IBAction)shareViaEmail;
- (IBAction)shareViaTwitter;
- (IBAction)shareViaFacebook;
- (IBAction)shareViaSMS;
- (IBAction)refreshList;
- (IBAction)openInMaps;
- (IBAction)startGameCountdown;
- (IBAction)assignTeams;


@end
