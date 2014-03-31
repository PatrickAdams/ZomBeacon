//
//  TutorialViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 3/25/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    for (UILabel * label in self.titilliumRegularFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:label.font.pointSize];
    }
    
    if (IS_IPHONE4S)
    {
        self.scrollView.contentSize = CGSizeMake(320, 650);
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake(320, 500);
    }
}

- (IBAction)helpDocs
{
    // Set this up once when your application launches
    UVConfig *config = [UVConfig configWithSite:@"zombeacon.uservoice.com"];
    config.showContactUs = NO;
    config.showForum = NO;
    config.showPostIdea = NO;
    [UserVoice initialize:config];
    
    // Call this wherever you want to launch UserVoice
    [UserVoice presentUserVoiceInterfaceForParentViewController:self];
}

- (IBAction)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
