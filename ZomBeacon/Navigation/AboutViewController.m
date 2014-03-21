//
//  AboutViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 3/21/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentUser = [PFUser currentUser];
    
    // Set this up once when your application launches
    UVConfig *config = [UVConfig configWithSite:@"zombeacon.uservoice.com"];
    config.showKnowledgeBase = NO;
    config.showForum = NO;
    config.showPostIdea = NO;
    [config identifyUserWithEmail:self.currentUser[@"email"] name:self.currentUser[@"name"] guid:self.currentUser[@"username"]];
    [UserVoice initialize:config];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Share Methods for Twitter, Facebook, and Email

- (IBAction)showShareActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Invite Friends"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Facebook", @"Twitter", @"SMS", @"Email", nil];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:@"Email"])
    {
        [self displayComposerSheet:[NSString stringWithFormat:@"You've been invited to download the ZomBeacon. ZomBeacon allows you to create your own Zombie apocalypse right in your own neighborhood. Become a zombie and infect your friends. Become a survivor and eliminate the zombies. To download the app visit this link <a href='http://bit.ly/zombeacon'>http://bit.ly/zombeacon</a>."]];
    }
    if ([buttonTitle isEqualToString:@"SMS"])
    {
        MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            vc.body = [NSString stringWithFormat:@"You've been invited to try out ZomBeacon: A zombie apocalypse right in your own neighborhood. Available now for iOS! Download now - http://bit.ly/zombeacon"];
            vc.messageComposeDelegate = self;
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
    if ([buttonTitle isEqualToString:@"Facebook"])
    {
        FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
        params.link = [NSURL URLWithString:@"http://bit.ly/zombeacon"];
        params.name = @"ZomBeacon: A zombie apocalypse right in your own neighborhood. Available now for iOS!";
        params.description = @"Become a Zombie and Infect Your Friends";
        params.picture = [NSURL URLWithString:@"http://i.imgur.com/SadmerX.png"];
        
        // If the Facebook app is installed and we can present the share dialog
        if ([FBDialogs canPresentShareDialogWithParams:params]) {
            // Present share dialog
            [FBDialogs presentShareDialogWithLink:params.link
                                             name:params.name
                                          caption:nil
                                      description:params.description
                                          picture:params.picture
                                      clientState:nil
                                          handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                              if(error) {
                                                  // There was an error
                                                  NSLog(@"%@",[NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                              } else {
                                                  // Success
                                                  NSLog(@"result %@", results);
                                              }
                                          }
             ];
        }
        else
        {
            // Put together the dialog parameters
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @"ZomBeacon: A zombie apocalypse right in your own neighborhood. Available now for iOS!", @"name",
                                           @"Become a Zombie and Infect Your Friends", @"description",
                                           @"http://bit.ly/zombeacon", @"link",
                                           @"http://i.imgur.com/SadmerX.png", @"picture",
                                           nil];
            
            // Show the feed dialog
            [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                if (error)
                {
                    NSLog(@"%@",[NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                }
                else
                {
                    if (result == FBWebDialogResultDialogNotCompleted)
                    {
                        NSLog(@"User cancelled.");
                    }
                    else
                    {
                        NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                        
                        if (![urlParams valueForKey:@"post_id"])
                        {
                            NSLog(@"User cancelled.");
                        }
                        else
                        {
                            NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                            NSLog(@"result %@", result);
                        }
                    }
                }
            }];
        }
    }
    if ([buttonTitle isEqualToString:@"Twitter"])
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
        
        [tweetComposer setInitialText:@"ZomBeacon: A zombie apocalypse right in your own neighborhood. Available now for iOS! #ZomBeacon"];
        [tweetComposer addURL:[NSURL URLWithString:@"http://bit.ly/zombeacon"]];
        
        [self presentViewController:tweetComposer animated:YES completion:nil];
        
    }
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs)
    {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

// Displays an email composition interface inside the application. Populates all the Mail fields.
- (void)displayComposerSheet:(NSString *)body {
    
	MFMailComposeViewController *mailComposerView = [[MFMailComposeViewController alloc] init];
    
    if ([MFMailComposeViewController canSendMail])
    {
        mailComposerView.mailComposeDelegate = self;
        [mailComposerView setSubject:@"You've Been Invited to a ZomBeacon Game!"];
        [mailComposerView setMessageBody:body isHTML:YES];
        
        [self presentViewController:mailComposerView animated:YES completion:nil];
    }
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

#pragma mark - UserVoice

- (IBAction)leaveFeedback
{
    [UserVoice presentUserVoiceContactUsFormForParentViewController:self];
}

@end
