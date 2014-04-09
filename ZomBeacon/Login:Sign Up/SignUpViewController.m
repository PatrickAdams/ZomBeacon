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
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    //Provides indentation for the textfields
    for (UITextField * textField in self.textFieldSpacers) {
        UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7.5, 7.5)];
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setLeftView:spacerView];
    }
    
    self.bioField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    
    if (IS_IPHONE4S)
    {
        self.scrollView.contentSize = CGSizeMake(320, 665);
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake(320, 560);
    }
}

- (void)keyboardDidShow
{
    if (IS_IPHONE4S)
    {
        self.scrollView.contentSize = CGSizeMake(320, 880);
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake(320, 790);
    }
}

- (BOOL)fieldsAreValid
{
    if (self.usernameField.text.length > 0 && self.passwordField.text.length > 0 && self.emailField.text.length > 0 && self.nameField.text > 0)
    {
        return TRUE;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account Creation Not Complete" message:@"You cannot leave any of the following fields blank: username, password, email, or name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
        return FALSE;
    }
}

- (BOOL)noWhiteSpaceInUsername
{
    NSRange whiteSpaceRange = [self.usernameField.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (whiteSpaceRange.location != NSNotFound)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Username Issue." message:@"Usernames cannot have any spaces." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}

//User sign up method using the Parse framework
- (IBAction)signUpNewUser
{
    if ([self fieldsAreValid] && [self noWhiteSpaceInUsername])
    {
        [self.bioField resignFirstResponder];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            PFUser *user = [PFUser user];
            
            user.username = self.usernameField.text;
            user.password = [self.passwordField.text lowercaseString];
            user.email = self.emailField.text;
            user[@"name"] = self.nameField.text;
            user[@"bio"] = self.bioField.text;
            user[@"minor"] = [NSNumber numberWithInt:[self getRandomNumberBetween:0 to:65535]];
            user[@"major"] = [NSNumber numberWithInt:[self getRandomNumberBetween:0 to:65535]];
            user[@"currentGame"] = @"";
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (!error)
                 {
                     //Create the UserScore row for the currentUser
                     PFObject *userScore = [PFObject objectWithClassName:@"UserScore"];
                     [userScore setObject:user forKey:@"user"];
                     [userScore saveInBackground];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                     });
                     
                     [PFUser logInWithUsernameInBackground:user.username password:user.password block:^(PFUser *user, NSError *error)
                      {
                          if (user)
                          {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                              });
                              
                              [self performSegueWithIdentifier:@"tutorial" sender:self];
                              [self performSegueWithIdentifier:@"mainmenu" sender:self];
                              
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Successful" message:@"You are now logged in." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                              
                              [alert show];
                          }
                          else
                          {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                              });
                              
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", [error userInfo][@"error"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                              
                              [alert show];
                          }
                      }];

                 }
                 else
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", [error userInfo][@"error"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     
                     [alert show];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                     });
                 }
             }];
        });
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 100) ? NO : YES;
}

//Method that chooses a random number
-(int)getRandomNumberBetween:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
