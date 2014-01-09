//
//  SignUpViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

//User sign up method using the Parse framework
- (IBAction)signUpNewUser
{
    PFUser *user = [PFUser user];
    user.username = self.usernameField.text;
    user.password = self.passwordField.text;
    user.email = self.emailField.text;
    
    // other fields can be set just like with PFObject
    user[@"name"] = self.nameField.text;
    user[@"bio"] = self.bioField.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (!error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Successful!"
                                                            message:@"You have successfully signed up."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"%@", errorString);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
