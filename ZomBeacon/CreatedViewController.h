//
//  CreatedViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreatedViewController : UIViewController

@property (nonatomic, weak) NSString *gameNameString;
@property (nonatomic, weak) NSString *createdByString;
@property (nonatomic, weak) NSString *dateTimeString;
@property (nonatomic, weak) NSString *locationString;
@property (nonatomic, weak) NSString *inviteCodeString;
@property (nonatomic, weak) IBOutlet UILabel *gameNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *createdByLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *inviteCodeLabel;

@end
