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
    
    currentUser = [PFUser currentUser];
	
    //MapView stuff
    self.mapView.delegate = self;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //user needs to press and hold for 1 second
    [self.mapView addGestureRecognizer:lpgr];
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
    
    //Provides indentation for the textfields
    for (UITextField * textField in self.textFieldSpacers) {
        UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7.5, 7.5)];
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setLeftView:spacerView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];
    
    if (IS_IPHONE4S)
    {
        self.scrollView.contentSize = CGSizeMake(320, 725);
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake(320, 568);
    }
}

- (void)keyboardDidHide
{
    if (IS_IPHONE4S)
    {
        self.scrollView.contentSize = CGSizeMake(320, 725);
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake(320, 568);
    }
}

- (void)keyboardDidShow
{
    if (IS_IPHONE4S)
    {
        self.scrollView.contentSize = CGSizeMake(320, 925);
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake(320, 870);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self zoomToUserLocation:self.mapView.userLocation];
}

#pragma mark - Game Creation Methods

//Method to put pin on map and save it's coordinates
- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    [self.mapView removeAnnotation:self.droppedPin];
    self.droppedPin = [[UserAnnotations alloc] init];
    self.droppedPin.coordinate = touchMapCoordinate;
    [self.mapView addAnnotation:self.droppedPin];
}

//Method for creating a new private game and saving it to Parse
- (IBAction)createNewGame
{
    PFObject *privateGame = [PFObject objectWithClassName:@"PrivateGames"];
    PFGeoPoint *gameLocation = [PFGeoPoint geoPointWithLatitude:self.droppedPin.coordinate.latitude longitude:self.droppedPin.coordinate.longitude];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CreatedViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"createdview"];
    
    if (![self.gameNameTextField.text isEqual:@""] && ![self.dateTimeTextField.text isEqual:@""] && gameLocation.latitude != 0)
    {
        privateGame[@"gameName"] = self.gameNameTextField.text;
        privateGame[@"hostUser"] = currentUser;
        privateGame[@"dateTime"] = self.dateTimeTextField.text;
        privateGame[@"location"] = gameLocation;
        privateGame[@"uuid"] = [[NSUUID UUID] UUIDString];
        privateGame[@"uuid2"] = [[NSUUID UUID] UUIDString];
        [privateGame save];
        
        vc.gameNameString = privateGame[@"gameName"];
        vc.gameHostString = currentUser[@"name"];
        vc.gameDateString = privateGame[@"dateTime"];
        
        CLLocationCoordinate2D gameLocationCoords = CLLocationCoordinate2DMake(gameLocation.latitude, gameLocation.longitude);
        
        vc.gameLocationCoord = gameLocationCoords;
        vc.gameIdString = privateGame.objectId;
        
        [self.navigationController pushViewController:vc animated:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SUCCESS" message:@"This game has been added to your profile." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    else if (gameLocation.latitude == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"You must drop a pin for the location of the game." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"All fields are required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}


#pragma mark - UIDatePicker Methods

//Date picker setup
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
    [self.datePicker setMinimumDate:[NSDate date]];
    self.datePicker.minuteInterval = 5;
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
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.view addSubview:self.pickerView];
    [self.view addSubview:self.datePicker];
}

//Method for when the user selects done on the UIDatePicker toolbar
- (void)pickerDoneClicked:(id)sender
{
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

#pragma mark - Map Stuff

//Method to zoom to the user location
- (void)zoomToUserLocation:(MKUserLocation *)userLocation
{
    if (!userLocation)
    {
        return;
    }
    
    MKCoordinateRegion region;
    region.center = userLocation.location.coordinate;
    region.span = MKCoordinateSpanMake(0.050, 0.050); //Zoom distance
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
