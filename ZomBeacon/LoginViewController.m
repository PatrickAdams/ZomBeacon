//
//  LoginViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    self.navigationItem.hidesBackButton = YES;
    
    [super viewDidLoad];
    
    //Checks to make sure a user is logged in, if so, it skips the login screen
    currentUser = [PFUser currentUser];
    if (currentUser)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainMenuViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainmenu"];
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.usernameField.text = @"";
    self.passwordField.text = @"";
}

#pragma mark - User Login Methods - Normal, Facebook, and Twitter

//Method to log in the user using the Parse framework
-(IBAction)logInUser
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *username = self.usernameField.text;
        NSString *password = self.passwordField.text;
        
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error)
         {
             if (user)
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Successful!"
                                                                 message:@"You are now logged in."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                 });
                 
                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 MainMenuViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainmenu"];
                 [self.navigationController pushViewController:vc animated:YES];
             }
             else
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login credentials are incorrect."
                                                                 message:@"Please try again."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                 });
             }
         }];
    });
}

- (IBAction)logInWithFacebook
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // The permissions requested from the user
        NSArray *permissionsArray = @[ @"user_about_me", @"email"];
        
        // Login PFUser using Facebook
        [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error)
         {
             if (!user)
             {
                 if (!error)
                 {
                     NSLog(@"Uh oh. The user cancelled the Facebook login.");
                 }
                 else
                 {
                     NSLog(@"Uh oh. An error occurred: %@", error);
                 }
             }
             else if (user.isNew)
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign up successful!"
                                                                 message:@"You are now logged in."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
                 
                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 MainMenuViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainmenu"];
                 [self.navigationController pushViewController:vc animated:YES];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                 });
                 
                 // Create request for user's Facebook data
                 FBRequest *request = [FBRequest requestForMe];
                 
                 // Send request to Facebook
                 [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
                  {
                      if (!error)
                      {
                          // result is a dictionary with the user's Facebook data
                          NSDictionary *userData = (NSDictionary *)result;
                          
                          PFUser *user = [PFUser currentUser];
                          user.username = userData[@"username"];
                          user.email = userData[@"email"];
                          user[@"name"] = userData[@"name"];
                          user[@"bio"] = userData[@"bio"];
                          
                          [user saveInBackground];
                          
                          // Download the user's facebook profile picture
                          self.imageData = [[NSMutableData alloc] init];
                          
                          NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userData[@"id"]]];
                          
                          NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                                timeoutInterval:2.0f];
                     
                          NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
                          NSLog(@"%@", urlConnection);
                      }
                  }];
             }
             else
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Successful!"
                                                                 message:@"You are now logged in."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
                 
                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 MainMenuViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainmenu"];
                 [self.navigationController pushViewController:vc animated:NO];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                 });
             }
         }];
    });
}

-(IBAction)loginWithTwitter
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
            if (!user) {
                NSLog(@"Uh oh. The user cancelled the Twitter login.");
            }
            else if(user.isNew)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign up successful!"
                                                                message:@"You are now logged in."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                MainMenuViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainmenu"];
                [self.navigationController pushViewController:vc animated:YES];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
                
                NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
                NSURL *verify = [NSURL URLWithString:requestString];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
                [[PFTwitterUtils twitter] signRequest:request];
                NSURLResponse *response = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
                
                if ( error == nil)
                {
                    NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                    
                    NSLog(@"%@", result);
                    
                    currentUser = [PFUser currentUser];
                    currentUser.username = [result objectForKey:@"screen_name"];
                    currentUser[@"name"] = [result objectForKey:@"name"];
                    currentUser[@"bio"] = [result objectForKey:@"description"];
                    
                    [user saveInBackground];
                    
                    // Download the user's twitter profile picture
                    self.imageData = [[NSMutableData alloc] init];
                    
                    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [result objectForKey:@"profile_image_url_https"]]];
                    
                    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                          timeoutInterval:2.0f];
                    
                    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
                    NSLog(@"%@", urlConnection);
                }
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Successful!"
                                                                message:@"You are now logged in."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                MainMenuViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainmenu"];
                [self.navigationController pushViewController:vc animated:NO];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }
        }];
    });
}

#pragma mark - Image Download Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}

//Once the image is done downloading, it saves it to the imageFile value for that User
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    PFFile *file = [[query getFirstObject] objectForKey:@"imageFile"];
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:self.imageData];
    
    if (!file)
    {
        // Save PFFile
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (!error)
             {
                 PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
                 [userPhoto setObject:imageFile forKey:@"imageFile"];
                 [userPhoto setObject:[PFUser currentUser] forKey:@"user"];
                 [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     
                 }];
             }
         }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
