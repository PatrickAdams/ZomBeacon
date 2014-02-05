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
    PFUser *currentUser = [PFUser currentUser];
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
        [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
            
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
                        
                        [user save];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
