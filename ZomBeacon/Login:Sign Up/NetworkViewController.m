//
//  NetworkViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 4/10/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "NetworkViewController.h"

@interface NetworkViewController ()

@end

@implementation NetworkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
