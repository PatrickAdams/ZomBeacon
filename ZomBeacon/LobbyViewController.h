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
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface LobbyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
{
    PFUser *currentUser;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *gameNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *startTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *hostUserLabel;
@property (nonatomic, weak) NSString *gameNameLabelString;
@property (nonatomic, weak) NSString *startTimeLabelString;
@property (nonatomic, weak) NSString *hostUserLabelString;
@property (nonatomic, weak) NSString *gameIdString;

- (NSMutableArray *)getPlayersInCurrentGame;
- (IBAction)shareWithFriends;
- (IBAction)refreshList;

@end
