//
//  PublicDeadViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 2/24/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "PublicDeadViewController.h"

@interface PublicDeadViewController ()

@end

@implementation PublicDeadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	currentUser = [PFUser currentUser];
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    self.navigationItem.hidesBackButton = YES;
}

//Sends you back to the main menu
- (IBAction)goHome
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Method that chooses a random number
-(int)getRandomNumberBetween:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
