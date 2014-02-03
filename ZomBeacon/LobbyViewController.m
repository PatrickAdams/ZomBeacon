//
//  LobbyViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/31/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "LobbyViewController.h"

@interface LobbyViewController ()

@end

@implementation LobbyViewController

- (void)viewDidLoad
{
    currentUser = [PFUser currentUser];
    [super viewDidLoad];
    
    self.gameNameLabel.text = self.gameNameString;
    self.gameHostLabel.text = self.gameHostString;
    self.gameDateLabel.text = self.gameDateString;
}

- (NSArray *)getPlayersInCurrentGame
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"currentGame" equalTo:currentUser[@"currentGame"]];
    NSArray *thePlayers = [query findObjects];

    return thePlayers;
}

- (IBAction)refreshList
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

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

- (IBAction)shareWithFriends
{
    [self displayComposerSheet:[NSString stringWithFormat:@"You've been invited to a game of ZomBeacon!</br></br>To join this game open the app and tap on 'Find Private Game' and paste in the following code:</br></br><strong>%@</strong></br></br><b>Game Details</b></br>Name: <i>%@</i></br>Time: <i>%@</i></br>Host: <i>%@</i></br>", self.gameIdString, self.gameNameString, self.gameDateString, self.gameHostString]];
}

// Displays an email composition interface inside the application. Populates all the Mail fields.
- (void)displayComposerSheet:(NSString *)body {
    
	MFMailComposeViewController *tempMailCompose = [[MFMailComposeViewController alloc] init];
    
	tempMailCompose.mailComposeDelegate = self;
    
	[tempMailCompose setSubject:@"You've Been Invited to a ZomBeacon Game!"];
	[tempMailCompose setMessageBody:body isHTML:YES];
    
	[self presentViewController:tempMailCompose animated:YES completion:nil];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Result: canceled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Result: saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Result: sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Result: failed");
			break;
		default:
			NSLog(@"Result: not sent");
			break;
	}
	[self dismissViewControllerAnimated:YES completion:nil];
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
