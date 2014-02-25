//
//  PublicDeadViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 2/24/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MainMenuViewController.h"

@interface PublicDeadViewController : UIViewController
{
    PFUser *currentUser;
}

- (IBAction)rejoinGame;
- (IBAction)goHome;

@end
