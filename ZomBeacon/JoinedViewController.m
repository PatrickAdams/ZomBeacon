//
//  JoinedViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "JoinedViewController.h"

@interface JoinedViewController ()

@end

@implementation JoinedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dateTimeLabel.text = self.dateTimeLabelString;
    self.locationLabel.text = self.locationLabelString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
