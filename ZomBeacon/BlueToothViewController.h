//
//  BlueToothViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/29/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LoginViewController.h"

@interface BlueToothViewController : UIViewController <CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;

@end
