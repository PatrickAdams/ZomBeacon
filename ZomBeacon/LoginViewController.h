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

@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) NSMutableData *imageData;

- (IBAction)logInUser;
- (IBAction)logInWithFacebook;

@end
