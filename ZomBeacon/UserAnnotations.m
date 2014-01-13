//
//  UserAnnotations.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/13/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "UserAnnotations.h"

@implementation UserAnnotations

@synthesize title, coordinate;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d {
    
	self = [super init];
	title = ttl;
	coordinate = c2d;
	return self;
}

@end
