//
//  PrivateLobbyViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 2/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "PrivateLobbyViewController.h"

@interface PrivateLobbyViewController ()

@end

@implementation PrivateLobbyViewController

- (void)viewDidLoad
{
    currentUser = [PFUser currentUser];
    [super viewDidLoad];
    
    // Create a geocoder and save it for later.
    self.geocoder = [[CLGeocoder alloc] init];
    
    //Sets values
    self.gameNameLabel.text = self.gameNameString;
    self.gameHostLabel.text = self.gameHostString;
    self.gameDateLabel.text = self.gameDateString;
    self.openInMapsButton.titleLabel.font = [UIFont fontWithName:@"04B_19" size:self.openInMapsButton.titleLabel.font.pointSize];
    
    for (UILabel * label in self.customFont) {
        label.font = [UIFont fontWithName:@"04B_19" size:label.font.pointSize];
    }
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.gameLocationCoord.latitude longitude:self.gameLocationCoord.longitude];
    
    //Reverse geocodes coordinates to a readable address for email sharing
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if ((placemarks != nil) && (placemarks.count > 0))
        {
			self.placemark = [placemarks objectAtIndex:0];
            self.gameAddressString = [NSString stringWithFormat:@"%@ %@. %@, %@ %@", self.placemark.subThoroughfare, self.placemark.thoroughfare, self.placemark.locality, self.placemark.administrativeArea, self.placemark.postalCode];
        }
    }];

    PFQuery *privateStatusQuery = [PFQuery queryWithClassName:@"PrivateStatus"];
    [privateStatusQuery whereKey:@"user" equalTo:currentUser];
    [privateStatusQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects.count == 0)
        {
            PFObject *privateStatus = [PFObject objectWithClassName:@"PrivateStatus"];
            [privateStatus setObject:currentUser forKey:@"user"];
            [privateStatus saveInBackground];
        }
        else
        {
            //Do nothing
        }
    }];
    
    //Checks if you are the host of the current game or not
    NSString *currentGame = currentUser[@"currentGame"];
    PFQuery *query = [PFQuery queryWithClassName:@"PrivateGames"];
    [query whereKey:@"objectId" equalTo:currentGame];
    [query includeKey:@"hostUser"];
    PFObject *theGame = [query getFirstObject];
    PFUser *theHost = theGame[@"hostUser"];
    
    if ([theHost.objectId isEqual:currentUser.objectId])
    {
        self.assignTeamsButton.hidden = NO;
        [self.startGameButton setEnabled:NO];
    }
    else
    {
        [self.startGameButton setEnabled:YES];
        self.assignTeamsButton.hidden = YES;
        [self.startGameButton isEnabled];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}

//Method to get players in game and add them to an array
- (NSArray *)getPlayersInCurrentGame
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"currentGame" equalTo:currentUser[@"currentGame"]];
    NSArray *thePlayers = [query findObjects];
    
    return thePlayers;
}

//Refreshes lobby
- (IBAction)refreshList
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

- (void)assignTeams
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        PFQuery *query = [PFUser query];
        [query whereKey:@"currentGame" equalTo:currentUser[@"currentGame"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *players, NSError *error) {
            
            NSMutableArray *playersArray = [players mutableCopy];
            NSUInteger totalPlayers = playersArray.count;
            NSUInteger totalZombies = ceil(totalPlayers * 0.2);
            
            for (int i = 0; i < playersArray.count; i++)
            {
                PFUser *player = playersArray[i];
                
                PFQuery *query = [PFQuery queryWithClassName:@"PrivateStatus"];
                [query whereKey:@"user" equalTo:player];
                PFObject *theStatus = [query getFirstObject];
                
                if (i < totalZombies)
                {
                    [theStatus setObject:@"zombie" forKey:@"status"];
                }
                else
                {
                    [theStatus setObject:@"survivor" forKey:@"status"];
                }
                
                [theStatus save];
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.startGameButton setEnabled:YES];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

- (IBAction)startGame
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PFQuery *query = [PFQuery queryWithClassName:@"PrivateStatus"];
    [query whereKey:@"user" equalTo:currentUser];
    PFObject *privateStatus = [query getFirstObject];
    
    if ([privateStatus[@"status"] isEqualToString:@"zombie"])
    {
        PrivateZombieViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"privateZombie"];
        [self.navigationController pushViewController:vc animated:YES];
        vc.navigationItem.hidesBackButton = YES;
    }
    else if ([privateStatus[@"status"] isEqualToString:@"survivor"])
    {
        PrivateSurvivorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"privateSurvivor"];
        [self.navigationController pushViewController:vc animated:YES];
        vc.navigationItem.hidesBackButton = YES;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Teams Not Yet Assigned" message:@"Host must assign teams before you can start." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    
}

//Method that chooses a random number
- (int)getRandomNumberBetween:(int)from to:(int)to
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

#pragma mark - Share Methods for Twitter, Facebook, and Email

- (IBAction)shareViaEmail
{
    [self displayComposerSheet:[NSString stringWithFormat:@"You've been invited to a game of ZomBeacon!</br></br>To join this game open the app and tap on 'Find Private Game' and paste in the following code:</br></br><strong>%@</strong></br></br><b>Game Details</b></br>Name: <i>%@</i></br>Time: <i>%@</i></br>Host: <i>%@</i></br>Address: %@", self.gameIdString, self.gameNameString, self.gameDateString, self.gameHostString, self.gameAddressString]];
}

// Displays an email composition interface inside the application. Populates all the Mail fields.
- (void)displayComposerSheet:(NSString *)body {
    
	MFMailComposeViewController *mailComposerView = [[MFMailComposeViewController alloc] init];
    
    if ([MFMailComposeViewController canSendMail])
    {
        mailComposerView.mailComposeDelegate = self;
        [mailComposerView setSubject:@"You've Been Invited to a ZomBeacon Game!"];
        [mailComposerView setMessageBody:body isHTML:YES];
        
        [self presentViewController:mailComposerView animated:YES completion:nil];
    }
	
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

- (IBAction)shareViaTwitter
{
    SLComposeViewController *tweetComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    tweetComposer.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
    };
    
    [tweetComposer setInitialText:[NSString stringWithFormat:@"Join my game of ZomBeacon! Enter code %@ in the 'Find Game' menu of the app to join. #zombeacon", self.gameIdString]];
    
    //    if (![tweetComposer addImage:[UIImage imageNamed:@"app_icon.png"]]) {
    //        NSLog(@"Unable to add the image!");
    //    }
    
    [self presentViewController:tweetComposer animated:YES completion:nil];
}

- (IBAction)shareViaFacebook
{
    SLComposeViewController *facebookComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    facebookComposer.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
    };
    
    [facebookComposer setInitialText:[NSString stringWithFormat:@"Join my game of ZomBeacon! Enter code %@ in the 'Find Game' menu of the app to join. #zombeacon", self.gameIdString]];
    
    //    if (![facebookComposer addImage:[UIImage imageNamed:@"app_icon.png"]]) {
    //        NSLog(@"Unable to add the image!");
    //    }
    
    [self presentViewController:facebookComposer animated:YES completion:nil];
}

#pragma mark - Open In Maps Method

//Method allows you to open the game coordinates in the Maps app
- (IBAction)openInMaps
{
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        CLLocationCoordinate2D coordinate = self.gameLocationCoord;
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:[NSString stringWithFormat:@"ZomBeacon: %@", self.gameNameString]];
        // Pass the map item to the Maps app
        [mapItem openInMapsWithLaunchOptions:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
