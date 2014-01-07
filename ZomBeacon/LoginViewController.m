//
//  LoginViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(IBAction)logInUser {
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                            MainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"pickateam"];
                                            [self presentViewController:vc animated:YES completion:nil];
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
