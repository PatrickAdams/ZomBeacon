//
//  CreatedViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "CreatedViewController.h"

@interface CreatedViewController ()

@end

@implementation CreatedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //MapView stuff
    self.mapView.delegate = self;
    
    self.navigationItem.hidesBackButton = YES;
	
    self.gameNameLabel.text = self.gameNameString;
    self.createdByLabel.text = self.createdByString;
    self.dateTimeLabel.text = self.dateTimeString;
    self.inviteCodeLabel.text = self.inviteCodeString;
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:self.gameLocationCoord];
    [annotation setTitle:self.gameNameString]; //You can set the subtitle too
    [self.mapView addAnnotation:annotation];
    
    [self zoomToPinLocation];
}

//Method to zoom to the user location
- (void)zoomToPinLocation
{
    MKCoordinateRegion region;
    region.center = self.gameLocationCoord;
    region.span = MKCoordinateSpanMake(0.005, 0.005); //Zoom distance
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:NO];
}

- (IBAction)shareWithFriends
{
    [self displayComposerSheet:[NSString stringWithFormat:@"You've been invited to a game of ZomBeacon!</br></br>To join this game open the app and tap on 'Find Private Game' and paste in the following code:</br></br><strong>%@</strong></br></br><b>Game Details</b></br>Name: <i>%@</i></br>Time: <i>%@</i></br>Host: <i>%@</i></br>", self.inviteCodeString, self.gameNameString, self.dateTimeString, self.createdByString]];
}

// Displays an email composition interface inside the application. Populates all the Mail fields.
- (void)displayComposerSheet:(NSString *)body {
    
	MFMailComposeViewController *tempMailCompose = [[MFMailComposeViewController alloc] init];
    
	tempMailCompose.mailComposeDelegate = self;
    
	[tempMailCompose setSubject:@"You've Been Invited to a ZomBeacon Game!"];
	[tempMailCompose setMessageBody:body isHTML:YES];
    
	[self presentViewController:tempMailCompose animated:YES completion:nil];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Result: canceled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Result: saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Result: sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Result: failed");
			break;
		default:
			NSLog(@"Result: not sent");
			break;
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
