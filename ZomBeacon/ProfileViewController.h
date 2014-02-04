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
#import "LobbyViewController.h"
#import "CustomButton.h"
#import "GameCell.h"

@interface ProfileViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *allImages;
    PFUser *currentUser;
    PFObject *privateGame;
}

@property (nonatomic, weak) IBOutlet UILabel *userName;
@property (nonatomic, weak) IBOutlet UILabel *realName;
@property (nonatomic, weak) IBOutlet UILabel *emailAddress;
@property (nonatomic, weak) IBOutlet UILabel *shortBio;
@property (nonatomic, weak) IBOutlet PFImageView *profileImage;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (NSArray *)getGamesUserHasCreated;
- (IBAction)cameraButtonTapped;
- (void)joinGameTapped:(UIButton *)sender;
- (void)uploadImage:(NSData *)imageData;
- (void)refreshImage;

@end
