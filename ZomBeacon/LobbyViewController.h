//
//  LobbyViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/31/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FriendProfileViewController.h"
#import "UserLobbyCell.h"
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <MapKit/MapKit.h>
#import <Social/Social.h>
#import "InfectedViewController.h"
#import "SurvivorViewController.h"

@interface LobbyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
{
    PFUser *currentUser;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *gameNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *gameDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *gameHostLabel;
@property (nonatomic, weak) IBOutlet UIButton *startGameButton;
@property (nonatomic, strong) NSString *gameNameString;
@property (nonatomic, strong) NSString *gameDateString;
@property (nonatomic, strong) NSString *gameHostString;
@property (nonatomic, strong) NSString *gameIdString;
@property (nonatomic, strong) NSString *gameAddressString;
@property (nonatomic, readwrite) CLLocationCoordinate2D gameLocationCoord;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) MKPlacemark *placemark;
@property (nonatomic, weak) IBOutlet UIView *shareView;


- (NSArray *)getPlayersInCurrentGame;
- (IBAction)shareViaEmail;
- (IBAction)shareViaTwitter;
- (IBAction)shareViaFacebook;
- (IBAction)refreshList;
- (IBAction)openInMaps;
- (IBAction)startGame;

@end
