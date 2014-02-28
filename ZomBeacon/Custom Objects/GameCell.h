//
//  GameCell.h
//  ZomBeacon
//
//  Created by Patrick Adams on 2/4/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *gameName;
@property (nonatomic, weak) IBOutlet UILabel *gameDate;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumRegularFonts;

@end
