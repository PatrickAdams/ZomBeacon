//
//  EditProfileViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 2/5/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

@interface EditProfileViewController : UIViewController
{
    PFUser *currentUser;
}

@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *bioField;
@property (nonatomic, weak) IBOutlet UIButton *facebookButton;
@property (nonatomic, weak) IBOutlet UIButton *twitterButton;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;
@property (nonatomic, strong) IBOutletCollection (UITextField)NSArray *textFieldSpacers;

- (IBAction)saveProfileChanges;
- (IBAction)dismissView;
- (IBAction)linkAccountWithFacebook;
- (IBAction)linkAccountWithTwitter;
//- (IBAction)unlinkFromFacebook;
//- (IBAction)unlinkFromTwitter;

@end
