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
#import <MapKit/MapKit.h>
#import <Social/Social.h>
#import "PublicZombieViewController.h"
#import "PublicSurvivorViewController.h"

@interface PublicLobbyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *customFont;

- (NSMutableArray *)getPlayersInCurrentGame;

@end
