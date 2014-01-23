//
//  CreatedViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "CreatedViewController.h"

@interface CreatedViewController ()

@end

@implementation CreatedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
	
    self.gameNameLabel.text = self.gameNameString;
    self.createdByLabel.text = self.createdByString;
    self.dateTimeLabel.text = self.dateTimeString;
    self.locationLabel.text = self.locationString;
    self.inviteCodeLabel.text = self.inviteCodeString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
