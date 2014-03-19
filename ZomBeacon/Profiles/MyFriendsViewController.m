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
    
    [self refreshList];
	
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
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
        [self getFriends];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

- (NSArray *)getFriends
{
    self.myFriends = [[NSMutableArray alloc] init];
    self.nameAndScoreArray = [[NSMutableArray alloc] init];
    
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
        
        PFObject *friendship = [self.myFriends objectAtIndex:i];
        PFObject *friend = friendship[@"personFollowing"];
        
        NSMutableDictionary *friendDict = [[NSMutableDictionary alloc] init];
        [friendDict setValue:friendship[@"personFollowing"] forKey:@"pointer"];
        [friendDict setValue:scoreTotal forKey:@"score"];
        [friendDict setValue:friend[@"name"] forKey:@"name"];
        [friendDict setValue:friend[@"username"] forKey:@"username"];
        [friendDict setValue:friend[@"bio"] forKey:@"bio"];
        
        [self.nameAndScoreArray addObject:friendDict];
    }
    
    NSSortDescriptor *sortDescriptorScore = [NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObjects:sortDescriptorScore, nil];
    
    self.friendsArray =[self.nameAndScoreArray sortedArrayUsingDescriptors:descriptors];
    
    return self.friendsArray;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userCell";
    UserLobbyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSObject *friend = [self.friendsArray objectAtIndex:[indexPath row]];
    cell.nameLabel.text = [friend valueForKey:@"name"];
    NSString *theScore = [NSString stringWithFormat:@"%@ pts", [[friend valueForKey:@"score"] stringValue]];
    cell.scoreLabel.text = theScore;
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query whereKey:@"user" equalTo:[friend valueForKey:@"pointer"]];
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
    
    NSObject *friend = [self.friendsArray objectAtIndex:[indexPath row]];

    vc.realNameString = [friend valueForKey:@"name"];
    vc.userNameString = [friend valueForKey:@"username"];
    vc.shortBioString = [friend valueForKey:@"bio"];
    vc.myFriend = [friend valueForKey:@"pointer"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

//Allowing the deletion of cells
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//Setting up what happens when you tap delete on a cell
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        PFObject *friendship = self.myFriends[indexPath.row];
        
        [friendship deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self getFriends];
            [self.tableView reloadData];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
