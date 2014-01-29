//
//  CreateViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "CreateViewController.h"

@interface CreateViewController ()

@end

@implementation CreateViewController

- (void)viewDidLoad
{
    [self setUpDatePicker];
    [super viewDidLoad];
	
    //MapView stuff
    self.mapView.delegate = self;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //user needs to press for 2 seconds
    [self.mapView addGestureRecognizer:lpgr];
}



- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    self.droppedPin = [[UserAnnotations alloc] init];
    self.droppedPin.coordinate = touchMapCoordinate;
    [self.mapView addAnnotation:self.droppedPin];
}

- (IBAction)createNewGame
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CreatedViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"createdview"];
    
    PFUser *user = [PFUser currentUser];
    PFObject *privateGame = [PFObject objectWithClassName:@"PrivateGames"];
    PFGeoPoint *gameLocation = [PFGeoPoint geoPointWithLatitude:self.droppedPin.coordinate.latitude longitude:self.droppedPin.coordinate.longitude];
    privateGame[@"gameName"] = self.gameNameTextField.text;
    privateGame[@"hostUser"] = user;
    privateGame[@"dateTime"] = self.dateTimeTextField.text;
    privateGame[@"location"] = gameLocation;
    [privateGame save];
    
    vc.gameNameString = privateGame[@"gameName"];
    vc.createdByString = user.username;
    vc.dateTimeString = privateGame[@"dateTime"];
    vc.gameLocationCoord = self.droppedPin.coordinate;
    vc.inviteCodeString = privateGame.objectId;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setUpDatePicker
{
    //Setting up the toolbar and adding a done button to it for the UIDatePicker
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleDefault;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(pickerDoneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    //Setting up the UIDatePicker in place of a standard keyboard
    self.datePicker = [[UIDatePicker alloc] init];
    [self.datePicker setDate:[NSDate date]];
    [self.datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [self.dateTimeTextField setInputView:self.datePicker];
    self.dateTimeTextField.inputAccessoryView = keyboardDoneButtonView;
    [self.datePicker removeFromSuperview];
    [self.pickerView removeFromSuperview];
}

//Update textfield with UIDatePicker value
-(void)updateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.dateTimeTextField.inputView;
    self.dateTimeTextField.text = [self formatDate:picker.date];
}

//Pop up UIDatePicker when user taps in field
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.view addSubview:self.pickerView];
    [self.view addSubview:self.datePicker];
}

//Method for when the user selects done on the UIDatePicker toolbar
- (void)pickerDoneClicked:(id)sender {
    [self.datePicker removeFromSuperview];
    [self.pickerView removeFromSuperview];
    [self.dateTimeTextField resignFirstResponder];
}

//Formats the date to a more readable format
- (NSString *)formatDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setDateFormat:@"'m'/'dd'"];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return formattedDate;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
