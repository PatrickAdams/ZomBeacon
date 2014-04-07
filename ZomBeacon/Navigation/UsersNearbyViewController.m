//
//  UsersNearbyViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 4/4/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "UsersNearbyViewController.h"

@interface UsersNearbyViewController ()

@end

@implementation UsersNearbyViewController

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
    
    self.selectedCells = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    if (currentUser[@"location"])
    {
        PFGeoPoint *userGeoPoint = currentUser[@"location"];
        PFQuery *query = [PFUser query];
        [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:0.125];
        [query whereKey:@"objectId" notEqualTo:currentUser.objectId];
        self.thePlayers = [query findObjects];
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
    UserLobbyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UserLobbyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if([self.selectedCells containsObject:[self.thePlayers objectAtIndex:indexPath.row]])
    {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
    }
    else
    {
        cell.accessoryView = nil;
    }
    
    PFObject *player = self.thePlayers[indexPath.row];
    NSString *playerName = player[@"username"];
    cell.nameLabel.text = playerName;
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query whereKey:@"user" equalTo:player];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        PFFile *file = object[@"imageFile"];
        cell.profileImage.image = [UIImage imageNamed:@"default_profile"];
        cell.profileImage.file = file;
        [cell.profileImage loadInBackground];
    }];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([selectedCell accessoryView] == nil)
    {
        selectedCell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
        [self.selectedCells addObject:[self.thePlayers objectAtIndex:indexPath.row]];
    }
    else
    {
        selectedCell.accessoryView = nil;
        [self.selectedCells removeObject:[self.thePlayers objectAtIndex:indexPath.row]];
    }
    
    NSLog(@"%@", [self.selectedCells valueForKey:@"username"]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (IBAction)sendInvite
{
    for (int i = 0; i < self.selectedCells.count; i++)
    {
        PFUser *player = self.selectedCells[i];
        
        //Set up push to send to person that bit you.
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"owner" equalTo:player];
        
        PFPush *push = [PFPush new];
        [push setQuery:pushQuery];
        [push setData:@{ @"alert": @"You've been invited to a game of ZomBeacon.", @"code": [NSString stringWithFormat:@"%@", self.gameIdString]}];
        [push sendPush:nil];
        
        [self.selectedCells removeAllObjects];
        [self refreshList];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"INVITES SENT" message:@"Invites successfully sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
        [self dismissView];
    }
 
}


@end
