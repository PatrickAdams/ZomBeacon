//
//  PasswordResetViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 2/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "PasswordResetViewController.h"

@interface PasswordResetViewController ()

@end

@implementation PasswordResetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
}

//Method that handles the resetting of the users password
- (IBAction)sendPasswordResetEmail
{
    [PFUser requestPasswordResetForEmailInBackground:self.emailField.text];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Reset!" message:@"Check your email for further instructions." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
