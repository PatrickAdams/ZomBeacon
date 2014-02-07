//
//  ProfileViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/17/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    currentUser = [PFUser currentUser];
    [super viewDidLoad];

    [self setProfileValues];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self refreshImage];
    
    [currentUser setObject:@"" forKey:@"privateStatus"];
    [currentUser setObject:@"" forKey:@"currentGame"];
    [currentUser saveInBackground];
    
    [self setProfileValues];
}

- (void)setProfileValues
{
    self.userName.text = currentUser.username;
    self.realName.text = currentUser[@"name"];
    self.emailAddress.text = currentUser.email;
    self.shortBio.text = currentUser[@"bio"];
}

#pragma mark - Facebook/Twitter Linking/Unlinking Methods

//Links the current user's ZomBeacon account with their Facebook account
- (IBAction)linkAccountWithFacebook
{
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:nil block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account Linked With Facebook!"
                                                                message:@"You have successfully linked your ZomBeacon account with Facebook"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}

//Unlinks the current user's ZomBeacon account from their Facebook account
- (IBAction)unlinkFromFacebook
{
    [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account Unlinked!"
                                                            message:@"You have successfully unlinked your ZomBeacon account to Facebook"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

//Links the current user's ZomBeacon account with their Twitter account
- (IBAction)linkAccountWithTwitter
{
    if (![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
            if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account Linked With Twitter!"
                                                                message:@"You have successfully linked your ZomBeacon account with Twitter"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}

//Unlinks the current user's ZomBeacon account from their Twitter account
- (IBAction)unlinkFromTwitter
{
    [PFTwitterUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
        if (!error && succeeded) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account Unlinked!"
                                                            message:@"You have successfully unlinked your ZomBeacon account to Twitter"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

#pragma mark - Camera Methods
- (IBAction)cameraButtonTapped
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [image drawInRect: CGRectMake(0, 0, 640, 960)];
    UIGraphicsEndImageContext();
    
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(image, 0.05f);
    [self uploadImage:imageData];
}

//Saves image to Parse under the user's account
-(void)uploadImage:(NSData *)imageData
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query whereKey:@"user" equalTo:currentUser];
    PFFile *file = [[query getFirstObject] objectForKey:@"imageFile"];
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    if (!file) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            // Save PFFile
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                    // Create a PFObject around a PFFile and associate it with the current user
                    PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
                    [userPhoto setObject:imageFile forKey:@"imageFile"];
                    
                    [userPhoto setObject:currentUser forKey:@"user"];
                    
                    [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                        
                        if (!error) {
                            [self refreshImage];
                        }
                    }];
                }
            }];
        });
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
                    [query whereKey:@"user" equalTo:currentUser];
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *objects, NSError *error) {
                        if (!error) {
                            
                            PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
                            [objects setObject:imageFile forKey:@"imageFile"];
                            [objects saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                });
                                
                                if (!error) {
                                    [self refreshImage];
                                }
                            }];
                        }
                    }];
                }
            }];
        });
        [self refreshImage];
    }
}

- (void)refreshImage
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query whereKey:@"user" equalTo:currentUser];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFFile *file = object[@"imageFile"];
        self.profileImage.file = file;
        [self.profileImage loadInBackground];
    }];
}

- (NSArray *)getGamesUserHasCreated
{
    PFQuery *query = [PFQuery queryWithClassName:@"PrivateGames"];
    [query whereKey:@"hostUser" equalTo:currentUser];
    [query includeKey:@"hostUser"];
    NSArray *privateGames = [query findObjects];
    
    return privateGames;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getGamesUserHasCreated].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"gameCell";
    GameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *game = [self getGamesUserHasCreated][indexPath.row];
    cell.gameName.text = game[@"gameName"];
    cell.gameDate.text = game[@"dateTime"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PrivateLobbyViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"privateLobby"];
    [self.navigationController pushViewController:vc animated:YES];
    
    PFObject *game = [self getGamesUserHasCreated][indexPath.row];
    
    [currentUser setObject:game.objectId forKey:@"currentGame"];
    [currentUser saveInBackground];
    
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
