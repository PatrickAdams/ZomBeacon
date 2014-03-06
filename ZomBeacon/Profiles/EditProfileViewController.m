//
//  EditProfileViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 2/5/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "EditProfileViewController.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	currentUser = [PFUser currentUser];
    
    self.nameField.text = currentUser[@"name"];
    self.usernameField.text = currentUser.username;
    self.emailField.text = currentUser.email;
    self.bioField.text = currentUser[@"bio"];
    
    if ([PFFacebookUtils isLinkedWithUser:currentUser])
    {
        [self.facebookButton setEnabled:NO];
    }
    
    if ([PFTwitterUtils isLinkedWithUser:currentUser])
    {
        [self.twitterButton setEnabled:NO];
    }
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    //Provides indentation for the textfields
    for (UITextField * textField in self.textFieldSpacers) {
        UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setLeftView:spacerView];
    }
}

- (IBAction)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveProfileChanges
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    currentUser[@"name"] = self.nameField.text;
    currentUser.username = self.usernameField.text;
    currentUser.email = self.emailField.text;
    currentUser[@"bio"] = self.bioField.text;
    
    [currentUser saveInBackground];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Changes Saved!" message:@"The changes you've made have been saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Facebook/Twitter Linking/Unlinking Methods

//Links the current user's ZomBeacon account with their Facebook account
- (IBAction)linkAccountWithFacebook
{
    if (![PFFacebookUtils isLinkedWithUser:currentUser])
    {
        [PFFacebookUtils linkUser:currentUser permissions:nil block:^(BOOL succeeded, NSError *error) {
            if (!error)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account Linked With Facebook!" message:@"You have successfully linked your ZomBeacon account with Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
                
                [self.facebookButton setEnabled:NO];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", [error userInfo][@"error"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
            }
        }];
    }
}

////Unlinks the current user's ZomBeacon account from their Facebook account
//- (IBAction)unlinkFromFacebook
//{
//    [PFFacebookUtils unlinkUserInBackground:currentUser block:^(BOOL succeeded, NSError *error) {
//        if (succeeded)
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account Unlinked!" message:@"You have successfully unlinked your ZomBeacon account to Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            
//            [alert show];
//        }
//    }];
//}

//Links the current user's ZomBeacon account with their Twitter account
- (IBAction)linkAccountWithTwitter
{
    if (![PFTwitterUtils isLinkedWithUser:currentUser])
    {
        [PFTwitterUtils linkUser:currentUser block:^(BOOL succeeded, NSError *error) {
            if ([PFTwitterUtils isLinkedWithUser:currentUser])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account Linked With Twitter!" message:@"You have successfully linked your ZomBeacon account with Twitter" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
                
                [self.twitterButton setEnabled:NO];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", [error userInfo][@"error"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
            }
        }];
    }
}

////Unlinks the current user's ZomBeacon account from their Twitter account
//- (IBAction)unlinkFromTwitter
//{
//    [PFTwitterUtils unlinkUserInBackground:currentUser block:^(BOOL succeeded, NSError *error) {
//        if (!error && succeeded)
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account Unlinked!" message:@"You have successfully unlinked your ZomBeacon account to Twitter" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            
//            [alert show];
//        }
//    }];
//}

@end
