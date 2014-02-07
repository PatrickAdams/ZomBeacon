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
    currentUser = [PFUser currentUser];
    [super viewDidLoad];
}

//Method to get players in game and add them to an array
- (NSArray *)getPlayersInCurrentGame
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"joinedPublic" equalTo:@"YES"];
    NSArray *thePlayers = [query findObjects];

    return thePlayers;
}

//Refreshes lobby
- (IBAction)refreshList
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    [self getPlayersInCurrentGame];
    [self.tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

- (IBAction)startGame
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if ([currentUser[@"publicStatus"] isEqualToString:@"zombie"])
    {
        PublicZombieViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicZombie"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([currentUser[@"publicStatus"] isEqualToString:@"survivor"])
    {
        PublicSurvivorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicSurvivor"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        int randomNumber = [self getRandomNumberBetween:1 to:100];
        
        if (randomNumber < 25 )
        {
            PublicZombieViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicZombie"];
            [self.navigationController pushViewController:vc animated:YES];
            [currentUser setObject:@"zombie" forKey:@"publicStatus"];
            [currentUser saveInBackground];
        }
        else
        {
            PublicSurvivorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicSurvivor"];
            [self.navigationController pushViewController:vc animated:YES];
            [currentUser setObject:@"survivor" forKey:@"publicStatus"];
            [currentUser saveInBackground];
        }
    }
}

//Method that chooses a random number
-(int)getRandomNumberBetween:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
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
