//
//  ProfileViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/17/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "PrivateLobbyViewController.h"
#import "GameCell.h"
#import <GameKit/GameKit.h>

@interface ProfileViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, GKGameCenterControllerDelegate>
{
    NSMutableArray *allImages;
    PFUser *currentUser;
    PFObject *privateGame;
}

@property (nonatomic, weak) IBOutlet UILabel *userName;
@property (nonatomic, weak) IBOutlet UILabel *realName;
@property (nonatomic, weak) IBOutlet UILabel *emailAddress;
@property (nonatomic, weak) IBOutlet UILabel *shortBio;
@property (nonatomic, weak) IBOutlet UILabel *userScore;
@property (nonatomic, weak) IBOutlet PFImageView *profileImage;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *gamesArray;
@property (nonatomic, strong) NSMutableArray *privateGames;

- (NSMutableArray *)getGamesUserHasCreated;
- (IBAction)cameraButtonTapped;
- (IBAction)linkAccountWithFacebook;
- (IBAction)unlinkFromFacebook;
- (IBAction)linkAccountWithTwitter;
- (IBAction)unlinkFromTwitter;
- (IBAction)logUserOut;
- (IBAction)showLeaderboards;
- (void)uploadImage:(NSData *)imageData;
- (void)refreshImage;


@end
