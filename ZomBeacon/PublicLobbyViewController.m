//
//  PublicLobbyViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/31/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "PublicLobbyViewController.h"

@interface PublicLobbyViewController ()

@end

@implementation PublicLobbyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [PFUser currentUser];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self getPlayersInCurrentGame];
    [self.tableView reloadData];
}

//Method to get players in game and add them to an array
- (NSMutableArray *)getPlayersInCurrentGame
{
    NSMutableArray *thePlayers = nil;
    
    if (self.currentUser[@"location"])
    {
        PFGeoPoint *userGeoPoint = self.currentUser[@"location"];
        PFQuery *query = [PFUser query];
        [query whereKey:@"joinedPublic" equalTo:@"YES"];
        [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:0.25];
        thePlayers = (NSMutableArray *)[query findObjects];
        [thePlayers removeObjectAtIndex:0];
    }

    return thePlayers;
}

#pragma mark - Table View Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getPlayersInCurrentGame].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userCell";
    UserLobbyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *player = [self getPlayersInCurrentGame][indexPath.row];
    NSString *playerName = player[@"name"];
    cell.nameLabel.text = playerName;
    
    if ([player[@"publicStatus"] isEqualToString:@"zombie"]) {
        cell.nameLabel.textColor = [UIColor redColor];
    }
    else
    {
        cell.nameLabel.textColor = [UIColor blueColor];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query whereKey:@"user" equalTo:player];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFFile *file = object[@"imageFile"];
        cell.profileImage.file = file;
        [cell.profileImage loadInBackground];
    }];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FriendProfileViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"friendprofile"];
    
    PFUser *player = [self getPlayersInCurrentGame][indexPath.row];
    vc.realNameString = player[@"name"];
    vc.userNameString = player[@"username"];
    vc.shortBioString = player[@"bio"];
    vc.currentGameString = player[@"currentGame"];
    vc.myFriend = player;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
