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
    
    //Checks to make sure a user is logged in, if so, it skips the login screen
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GameViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainmenu"];
        [self.navigationController pushViewController:vc animated:NO];
    }
    
    [super viewDidLoad];
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
                 GameViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainmenu"];
                 [self.navigationController pushViewController:vc animated:YES];
                 
             } else {
                 
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
