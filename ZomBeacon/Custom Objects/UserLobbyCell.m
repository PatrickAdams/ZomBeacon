//
//  UserLobbyCell.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/31/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "UserLobbyCell.h"

@implementation UserLobbyCell

- (void)layoutSubviews
{
    for (UILabel * label in self.customFont) {
        label.font = [UIFont fontWithName:@"04B_19" size:label.font.pointSize];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
