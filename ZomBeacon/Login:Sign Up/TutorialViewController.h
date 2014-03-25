//
//  TutorialViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 3/25/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserVoice.h"

@interface TutorialViewController : UIViewController

@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumRegularFonts;

- (IBAction)helpDocs;
- (IBAction)dismissView;

@end
