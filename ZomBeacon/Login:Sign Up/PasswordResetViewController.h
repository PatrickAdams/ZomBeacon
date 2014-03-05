//
//  PasswordResetViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 2/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PasswordResetViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *emailField;

- (IBAction)sendPasswordResetEmail;
- (IBAction)dismissView;

@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;
@property (nonatomic, strong) IBOutletCollection (UITextField)NSArray *textFieldSpacers;

@end
