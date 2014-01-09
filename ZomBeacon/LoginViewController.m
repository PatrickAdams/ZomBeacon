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
    [super viewDidLoad];
	
    //Checks to make sure a user is logged in, if so, it skips the login screen
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"pickateam"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        //Stay on login screen
    }
}

//Method to log in the user using the Parse framework
-(IBAction)logInUser {
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error)
    {
        if (user)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"pickateam"];
            [self.navigationController pushViewController:vc animated:YES];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Successful!"
                                                            message:@"You are now logged in."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        } else {
            self.statusText.textColor = [UIColor redColor];
            self.statusText.text = @"USER DOES NOT EXIST!";
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
