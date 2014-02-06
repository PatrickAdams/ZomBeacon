//
//  PublicLobbyViewController.h
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
#import "PublicZombieViewController.h"
#import "PublicSurvivorViewController.h"

@interface PublicLobbyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
{
    PFUser *currentUser;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *startGameButton;

- (NSArray *)getPlayersInCurrentGame;
- (IBAction)refreshList;
- (IBAction)startGame;

@end
