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
    
    currentUser = [PFUser currentUser];
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"joinedPublic" equalTo:@"YES"];
    [query whereKey:@"publicStatus" equalTo:@"zombie"];
    NSArray *theZombies = [query findObjects];
    self.totalZombiesGlobally.text = [NSString stringWithFormat:@"%lu", (unsigned long)theZombies.count];
    
    PFQuery *query2 = [PFUser query];
    [query2 whereKey:@"joinedPublic" equalTo:@"YES"];
    [query2 whereKey:@"publicStatus" equalTo:@"survivor"];
    NSArray *theSurvivors = [query2 findObjects];
    self.totalSurvivorsGlobally.text = [NSString stringWithFormat:@"%lu", (unsigned long)theSurvivors.count];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self refreshList];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}

- (void)refreshList
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self getPlayersInCurrentGame];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

//Method to get players in game and add them to an array
- (NSArray *)getPlayersInCurrentGame
{
    self.thePlayers = nil;
    self.theScores  = [[NSMutableArray alloc] init];
    
    if (currentUser[@"location"])
    {
        PFGeoPoint *userGeoPoint = currentUser[@"location"];
        PFQuery *query = [PFUser query];
        [query whereKey:@"joinedPublic" equalTo:@"YES"];
        [query whereKey:@"publicStatus" notEqualTo:@"dead"];
        [query whereKey:@"objectId" notEqualTo:currentUser.objectId];
        [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:0.25];
        self.thePlayers = [query findObjects];
        
        for (int i = 0; i < self.thePlayers.count; i++)
        {
            PFUser *user = [self.thePlayers objectAtIndex:i];
            PFQuery *scoreQuery = [PFQuery queryWithClassName:@"UserScore"];
            [scoreQuery whereKey:@"user" equalTo:user];
            PFObject *theUserScore = [scoreQuery getFirstObject];
            
            NSNumber *publicScore = theUserScore[@"publicScore"];
            NSNumber *privateScore = theUserScore[@"privateScore"];
            NSNumber *scoreTotal = [NSNumber numberWithFloat:([publicScore floatValue] + [privateScore floatValue])];
            
            [self.theScores addObject:scoreTotal];
        }
    }
    
    return self.thePlayers;
}

#pragma mark - Table View Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.thePlayers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userCell";
    UserLobbyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *player = self.thePlayers[indexPath.row];
    NSString *playerName = player[@"username"];
    cell.nameLabel.text = playerName;
    
    if ([player[@"publicStatus"] isEqualToString:@"zombie"])
    {
        cell.nameLabel.textColor = [UIColor colorWithRed:0.99 green:0.33 blue:0.16 alpha:1];
    }
    else if ([player[@"publicStatus"] isEqualToString:@"survivor"])
    {
        cell.nameLabel.textColor = [UIColor colorWithRed:0.13 green:0.79 blue:0.5 alpha:1];
    }
    
    NSString *theScore = [NSString stringWithFormat:@"%@ pts.", [self.theScores objectAtIndex:indexPath.row]];
    cell.scoreLabel.text = theScore;
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query whereKey:@"user" equalTo:player];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFFile *file = object[@"imageFile"];
        cell.profileImage.file = nil;
        cell.profileImage.file = file;
        [cell.profileImage loadInBackground];
    }];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FriendProfileViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"friendprofile"];
    
    NSString *theScore = [NSString stringWithFormat:@"%@ pts", [self.theScores objectAtIndex:indexPath.row]];
    
    PFUser *player = self.thePlayers[indexPath.row];
    vc.realNameString = player[@"name"];
    vc.userNameString = player[@"username"];
    vc.shortBioString = player[@"bio"];
    vc.currentGameString = player[@"currentGame"];
    vc.userScoreString = theScore;
    vc.myFriend = player;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
