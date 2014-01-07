//
//  LoginViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UILabel *statusText;

-(IBAction)logInUser;

@end
