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

@end
