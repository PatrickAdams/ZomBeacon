//
//  EndGameViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 3/12/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivateLobbyViewController.h"
#import <Parse/Parse.h>

@interface EndGameViewController : UIViewController

@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumRegularFonts;
@property (nonatomic, weak) IBOutlet UILabel *winnerLabel;

- (IBAction)goHome;

@end
