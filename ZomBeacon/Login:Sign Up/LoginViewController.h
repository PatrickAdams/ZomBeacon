//
//  LoginViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "MainMenuViewController.h"
#import "SignUpViewController.h"

@interface LoginViewController : UIViewController <NSURLConnectionDelegate>
{
    PFUser *currentUser;
}

@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) NSMutableData *imageData;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;
@property (nonatomic, weak) IBOutlet UIButton *forgotPasswordButton;
@property (nonatomic, weak) IBOutlet UIButton *signUpButton;


- (IBAction)logInUser;
- (IBAction)logInWithFacebook;
- (IBAction)loginWithTwitter;

@end
