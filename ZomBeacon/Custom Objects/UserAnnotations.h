//
//  UserAnnotations.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/13/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface UserAnnotations : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIButton *infoButton;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d andImage:(UIImage *)img;
- (MKAnnotationView *)annotationView;

@end
