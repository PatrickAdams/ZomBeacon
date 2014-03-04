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
    
    // Create a geocoder and save it for later.
    self.geocoder = [[CLGeocoder alloc] init];
    
    //MapView stuff
    self.mapView.delegate = self;
    
    //Hides back button
    self.navigationItem.hidesBackButton = YES;
	
    //Sets values
    self.gameNameLabel.text = self.gameNameString;
    self.gameHostLabel.text = self.gameHostString;
    self.gameDateLabel.text = self.gameDateString;
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:self.gameLocationCoord];
    [annotation setTitle:self.gameNameString]; //You can set the subtitle too
    [self.mapView addAnnotation:annotation];
    
    [self zoomToPinLocation];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.gameLocationCoord.latitude longitude:self.gameLocationCoord.longitude];
    
    //Reverse geocoding so the coordinates are readable for when sharing via email
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if ((placemarks != nil) && (placemarks.count > 0))
        {
			self.placemark = [placemarks objectAtIndex:0];
            self.gameAddressString = [NSString stringWithFormat:@"%@ %@. %@, %@ %@", self.placemark.subThoroughfare, self.placemark.thoroughfare, self.placemark.locality, self.placemark.administrativeArea, self.placemark.postalCode];
        }
    }];
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
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

#pragma mark - Share Methods for Twitter, Facebook, and Email

- (IBAction)shareViaEmail
{
    [self displayComposerSheet:[NSString stringWithFormat:@"You've been invited to a game of ZomBeacon!</br></br>To join this game tap the code below:</br></br><strong><a href='ZomBeacon://?invite=%@'>%@</a></strong></br></br><b>Game Details</b></br>Name: <i>%@</i></br>Time: <i>%@</i></br>Host: <i>%@</i></br>Address: %@", self.gameIdString, self.gameIdString, self.gameNameString, self.gameDateString, self.gameHostString, self.gameAddressString]];
}

// Displays an email composition interface inside the application. Populates all the Mail fields.
- (void)displayComposerSheet:(NSString *)body
{
	MFMailComposeViewController *tempMailCompose = [[MFMailComposeViewController alloc] init];
    
	tempMailCompose.mailComposeDelegate = self;
    
	[tempMailCompose setSubject:@"You've Been Invited to a ZomBeacon Game!"];
	[tempMailCompose setMessageBody:body isHTML:YES];
    
	[self presentViewController:tempMailCompose animated:YES completion:nil];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
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

- (IBAction)shareViaTwitter
{
    SLComposeViewController *tweetComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    tweetComposer.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
    };
    
    [tweetComposer setInitialText:@"You've been invited to a game of ZomBeacon, click the link to join! #ZomBeacon"];
    [tweetComposer addURL:[NSURL URLWithString:[NSString stringWithFormat:@"ZomBeacon://?invite=%@", self.gameIdString]]];
    
    //    if (![tweetComposer addImage:[UIImage imageNamed:@"app_icon.png"]]) {
    //        NSLog(@"Unable to add the image!");
    //    }
    
    [self presentViewController:tweetComposer animated:YES completion:nil];
}

- (IBAction)shareViaFacebook
{
    SLComposeViewController *facebookComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    facebookComposer.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
    };
    
    [facebookComposer setInitialText:@"You've been invited to a game of ZomBeacon, click the link to join! #ZomBeacon"];
    [facebookComposer addURL:[NSURL URLWithString:[NSString stringWithFormat:@"ZomBeacon://?invite=%@", self.gameIdString]]];
    
    //    if (![facebookComposer addImage:[UIImage imageNamed:@"app_icon.png"]]) {
    //        NSLog(@"Unable to add the image!");
    //    }
    
    [self presentViewController:facebookComposer animated:YES completion:nil];
}

- (IBAction)shareViaSMS
{
    MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        vc.body = [NSString stringWithFormat:@"You've been invited to a game of ZomBeacon! To join this game click the following link: ZomBeacon://?invite=%@ Game Details - Name: %@ Time: %@ Host: %@ Address: %@", self.gameIdString, self.gameNameString, self.gameDateString, self.gameHostString, self.gameAddressString];
        vc.messageComposeDelegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
