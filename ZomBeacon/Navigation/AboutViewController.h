//
//  AboutViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 3/21/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "UserVoice.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

@interface AboutViewController : UIViewController <UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) PFUser *currentUser;

- (IBAction)leaveFeedback;

@end
