//
//  FindViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "GameDetailsViewController.h"

@interface FindGameViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *findGameField;

- (IBAction)findGame;

@end
