//
//  MyFriendsViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 3/4/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "MyFriendsViewController.h"

@interface MyFriendsViewController ()

@end

@implementation MyFriendsViewController

- (void)viewDidLoad
{
    self.currentUser = [PFUser currentUser];
    [super viewDidLoad];
	
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self getFriends];
    [self.tableView reloadData];
    
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}

- (NSMutableArray *)getFriends
{
    self.myFriends = nil;
    self.theScores  = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Friendships"];
    [query whereKey:@"user" equalTo:self.currentUser];
    [query includeKey:@"personFollowing"];
    self.myFriends = [[query findObjects] mutableCopy];
    
    for (int i = 0; i < self.myFriends.count; i++)
    {
        PFQuery *scoreQuery = [PFQuery queryWithClassName:@"UserScore"];
        [scoreQuery whereKey:@"user" equalTo:[self.myFriends objectAtIndex:i][@"personFollowing"]];
        PFObject *theUserScore = [scoreQuery getFirstObject];
        
        NSNumber *publicScore = theUserScore[@"publicScore"];
        NSNumber *privateScore = theUserScore[@"privateScore"];
        NSNumber *scoreTotal = [NSNumber numberWithFloat:([publicScore floatValue] + [privateScore floatValue])];
        
        [self.theScores addObject:scoreTotal];
    }
    
    return self.myFriends;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userCell";
    UserLobbyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *friendship = self.myFriends[indexPath.row];
    PFObject *friend = friendship[@"personFollowing"];
    cell.nameLabel.text = friend[@"name"];
    NSString *theScore = [NSString stringWithFormat:@"%@ pts", [[self.theScores objectAtIndex:[indexPath row]] stringValue]];
    cell.scoreLabel.text = theScore;
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query whereKey:@"user" equalTo:friend];
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
    
    PFObject *friendship = self.myFriends[indexPath.row];
    PFObject *friend = friendship[@"personFollowing"];
    vc.realNameString = friend[@"name"];
    vc.userNameString = friend[@"username"];
    vc.shortBioString = friend[@"bio"];
    vc.currentGameString = friend[@"currentGame"];
    vc.myFriend = (PFUser *)friend;
    
    [self.navigationController pushViewController:vc animated:YES];
}

////Allowing the deletion of cells
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

////Setting up what happens when you tap delete on a cell
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        PFObject *gameToBeDeleted = [self.privateGames objectAtIndex:indexPath.row];
//        [gameToBeDeleted deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//                [self getGamesUserHasCreated];
//                [self.tableView reloadData];
//            }
//        }];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
