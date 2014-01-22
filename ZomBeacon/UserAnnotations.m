//
//  UserAnnotations.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/13/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "UserAnnotations.h"

@implementation UserAnnotations

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d andImage:(UIImage *)img
{
	self = [super init];
    if (self)
    {
        _title = ttl;
        _coordinate = c2d;
        _image = img;
    }
	
	return self;
}

- (MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"CustomAnnotation"];
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.image = _image;
        
    return annotationView;
}

@end
