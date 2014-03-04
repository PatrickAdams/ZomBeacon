//
//  FriendProfileViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/31/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "FriendProfileViewController.h"

@interface FriendProfileViewController ()

@end

@implementation FriendProfileViewController

- (void)viewDidLoad
{
    self.currentUser = [PFUser currentUser];
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height /2;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderWidth = 2.0f;
    self.profileImage.layer.borderColor = [[UIColor colorWithRed:1 green:0.74 blue:0.27 alpha:1] CGColor];
    
    [self refreshImage];
    [super viewDidLoad];
    self.realName.text = self.realNameString;
    self.userName.text = self.userNameString;
    self.shortBio.text = self.shortBioString;
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
    
    PFQuery *friendshipQuery = [PFQuery queryWithClassName:@"Friendships"];
    [friendshipQuery whereKey:@"user" equalTo:self.currentUser];
    [friendshipQuery whereKey:@"personFollowing" equalTo:self.myFriend];
    [friendshipQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count == 1) {
            [self.addAsFriendButton setEnabled:NO];
        }
    }];
}

- (IBAction)followUser
{
    PFObject *friendship = [PFObject objectWithClassName:@"Friendships"];
    
    friendship[@"user"] = self.currentUser;
    friendship[@"personFollowing"] = self.myFriend;
    [friendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"You are now following %@", self.myFriend.username] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self getGamesUserHasCreated];
    [self.tableView reloadData];
    [self refreshImage];
    
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}

- (void)refreshImage
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query whereKey:@"user" equalTo:self.myFriend];
    
    PFFile *file = [query getFirstObject][@"imageFile"];
    self.profileImage.file = file;
    [self.profileImage loadInBackground];
}

#pragma mark - TableView Methods

- (NSMutableArray *)getGamesUserHasCreated
{
    self.privateGames = nil;
    
    PFQuery *query = [PFQuery queryWithClassName:@"PrivateGames"];
    [query whereKey:@"hostUser" equalTo:self.myFriend];
    [query includeKey:@"hostUser"];
    [query orderByAscending:@"dateTime"];
    self.privateGames = [[query findObjects] mutableCopy];
    
    return self.privateGames;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.privateGames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"gameCell";
    GameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *game = self.privateGames[indexPath.row];
    cell.gameName.text = game[@"gameName"];
    cell.gameDate.text = game[@"dateTime"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PrivateLobbyViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"privateLobby"];
    [self.navigationController pushViewController:vc animated:YES];
    
    PFObject *game = self.privateGames[indexPath.row];
    
    [self.currentUser setObject:game.objectId forKey:@"currentGame"];
    [self.currentUser saveInBackground];
    
    PFGeoPoint *gameLocation = game[@"location"];
    CLLocationCoordinate2D gameLocationCoords = CLLocationCoordinate2DMake(gameLocation.latitude, gameLocation.longitude);
    
    PFObject *hostUser = game[@"hostUser"];
    
    vc.gameNameString = game[@"gameName"];
    vc.gameDateString = game[@"dateTime"];
    vc.gameHostString = hostUser[@"name"];
    vc.gameIdString = game.objectId;
    vc.gameLocationCoord = gameLocationCoords;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
