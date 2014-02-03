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
    
    //Adds a button for each game you've created
    PFQuery *query = [PFQuery queryWithClassName:@"PrivateGames"];
    [query whereKey:@"hostUser" equalTo:currentUser];
    [query includeKey:@"hostUser"];
    NSArray *privateGames = [query findObjects];
    for (int i = 0; i < privateGames.count; i++)
    {
        privateGame = [privateGames objectAtIndex:i];
        CGRect r = CGRectMake(10, 0, 300, 50);
        r.origin.y = i * r.size.height + 3 * i;
        CustomButton *button = [[CustomButton alloc] initWithFrame:r];
        [button setTitle:[NSString stringWithFormat:@"Name: %@ Code: %@", privateGame[@"gameName"], privateGame.objectId] forState:UIControlStateNormal];
        button.titleLabel.textColor = [UIColor whiteColor];
        button.titleLabel.font = [UIFont fontWithName:@"helvetica" size:14];
        button.backgroundColor = [UIColor darkGrayColor];
        button.gameTitle = privateGame[@"gameName"];
        button.gameDate = privateGame[@"dateTime"];
        PFObject *hostUser = privateGame[@"hostUser"];
        button.gameHost = hostUser[@"name"];
        button.gameId = privateGame.objectId;
        [button addTarget:self action:@selector(joinGameTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        self.scrollView.contentSize = CGSizeMake(320, CGRectGetMaxY(button.frame));
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [currentUser setObject:@"" forKey:@"status"];
    [currentUser setObject:@"" forKey:@"currentGame"];
    [currentUser setObject:[NSNull null] forKey:@"location"];
    [currentUser saveInBackground];
}

- (void)joinGameTapped:(CustomButton *)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LobbyViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"gamelobby"];
    [self.navigationController pushViewController:vc animated:YES];
    
    [currentUser setObject:sender.gameId forKey:@"currentGame"];
    [currentUser save];
    
    vc.gameNameLabelString = sender.gameTitle;
    vc.startTimeLabelString = sender.gameDate;
    vc.hostUserLabelString = sender.gameHost;
    vc.gameIdString = sender.gameId;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
