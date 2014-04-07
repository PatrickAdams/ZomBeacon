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
        [query whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:0.25];
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
    
    if(1)//[self.selectedCells containsObject:[self.thePlayers objectAtIndex:indexPath.row]])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    PFObject *player = self.thePlayers[indexPath.row];
    NSString *playerName = player[@"username"];
    cell.nameLabel.text = playerName;
    
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
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([selectedCell accessoryType] == UITableViewCellAccessoryNone)
    {
        [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self.selectedCells addObject:[self.thePlayers objectAtIndex:indexPath.row]];
    }
    else
    {
        [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
        [self.selectedCells removeObject:[self.thePlayers objectAtIndex:indexPath.row]];
    }
    
    NSLog(@"%@", [self.selectedCells valueForKey:@"username"]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
