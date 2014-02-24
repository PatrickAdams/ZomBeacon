//
//  PrivateDeadViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 2/24/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "PrivateDeadViewController.h"

@interface PrivateDeadViewController ()

@end

@implementation PrivateDeadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (IBAction)goHome
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainMenuViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainmenu"];
    vc.navigationItem.hidesBackButton = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
