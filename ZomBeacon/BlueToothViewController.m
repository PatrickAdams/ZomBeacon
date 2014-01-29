//
//  BlueToothViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/29/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "BlueToothViewController.h"

@interface BlueToothViewController ()

@end

@implementation BlueToothViewController

- (void)viewDidLoad
{
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [self centralManagerDidUpdateState:self.centralManager];
    
    [super viewDidLoad];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"login"];
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
