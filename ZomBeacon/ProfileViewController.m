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
    [super viewDidLoad];
    
    currentUser = [PFUser currentUser];
    [self refreshImage];
    
    self.userName.text = currentUser.username;
    self.realName.text = currentUser[@"name"];
    self.emailAddress.text = currentUser.email;
    self.shortBio.text = currentUser[@"bio"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [currentUser setObject:@"" forKey:@"status"];
    [currentUser setObject:@"" forKey:@"currentGame"];
    [currentUser setObject:[NSNull null] forKey:@"location"];
    [currentUser saveInBackground];
}

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

-(void)uploadImage:(NSData *)imageData {
    
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
    LobbyViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"gamelobby"];
    [self.navigationController pushViewController:vc animated:YES];
    
    PFObject *game = [self getGamesUserHasCreated][indexPath.row];
    
    [currentUser setObject:game.objectId forKey:@"currentGame"];
    [currentUser save];
    
    PFGeoPoint *gameLocation = game[@"location"];
    CLLocationCoordinate2D gameLocationCoords = CLLocationCoordinate2DMake(gameLocation.latitude, gameLocation.longitude);

    PFObject *hostUser = privateGame[@"hostUser"];
    
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
