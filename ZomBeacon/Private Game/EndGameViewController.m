//
//  EndGameViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 3/12/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "EndGameViewController.h"

@interface EndGameViewController ()

@end

@implementation EndGameViewController

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

- (IBAction)goHome
{
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[PrivateLobbyViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
