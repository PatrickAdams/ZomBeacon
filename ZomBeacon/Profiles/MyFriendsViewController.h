//
//  MyFriendsViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 3/4/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "UserLobbyCell.h"
#import "FriendProfileViewController.h"

@interface MyFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *friendsArray;
@property (nonatomic, strong) NSMutableArray *myFriends;
@property (nonatomic, strong) NSMutableArray *theScores;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;

- (NSMutableArray *)getFriends;

@end
