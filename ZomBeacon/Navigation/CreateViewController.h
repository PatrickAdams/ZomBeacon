//
//  CreateViewController.h
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "CreatedViewController.h"
#import <MapKit/MapKit.h>
#import "UserAnnotations.h"

@interface CreateViewController : UIViewController <MKMapViewDelegate>
{
    PFUser *currentUser;
}

@property (nonatomic, weak) IBOutlet UITextField *gameNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *dateTimeTextField;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UserAnnotations *droppedPin;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumSemiBoldFonts;
@property (nonatomic, strong) IBOutletCollection (UILabel)NSArray *titilliumRegularFonts;
@property (nonatomic, strong) IBOutletCollection (UITextField)NSArray *textFieldSpacers;

- (IBAction)createNewGame;

@end
