//
//  CreateViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "CreatedViewController.h"

@interface CreateViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *gameNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *dateTimeTextField;
@property (nonatomic, weak) IBOutlet UITextField *locationTextField;

- (IBAction)createNewGame;

@end
