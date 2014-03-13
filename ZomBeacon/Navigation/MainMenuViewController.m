//
//  MainMenuViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/22/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;

    currentUser = [PFUser currentUser];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:22],
      NSFontAttributeName, [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1], NSForegroundColorAttributeName, nil]];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationItem.hidesBackButton = YES;
    
    //Refreshes currentUser data
    [currentUser refresh];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    [self saveLocation];
    
    //When user is on the menu, checks every minute for their location
    self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(saveLocation) userInfo:nil repeats:YES];
}

- (IBAction)inviteFriends
{
    //To-Do for Version 2.0 (once we have the link)
    //Bring up Twitter/Facebook with link to download the app in the AppStore.
}

- (void)saveLocation
{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        [currentUser setObject:geoPoint forKey:@"location"];
        [currentUser saveInBackground];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.locationTimer invalidate];
}

- (IBAction)startPublicGame
{
    if ([currentUser[@"publicStatus"] isEqualToString:@"zombie"])
    {
        [self performSegueWithIdentifier: @"publicZombie" sender: self];
    }
    else if ([currentUser[@"publicStatus"] isEqualToString:@"survivor"])
    {
        [self performSegueWithIdentifier: @"publicSurvivor" sender: self];
    }
    else if ([currentUser[@"publicStatus"] isEqualToString:@"dead"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"YOU ARE DEAD" message:@"Do you want to rejoin this game for -5,000 points?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        
        [alert show];
    }
    else
    {
        int randomNumber = [self getRandomNumberBetween:1 to:100];
        
        if (randomNumber < 20)
        {
            [self performSegueWithIdentifier: @"publicZombie" sender: self];
            [currentUser setObject:@"zombie" forKey:@"publicStatus"];
            [currentUser setObject:@"YES" forKey:@"joinedPublic"];
            [currentUser saveInBackground];
        }
        else
        {
            [self performSegueWithIdentifier: @"publicSurvivor" sender: self];
            [currentUser setObject:@"survivor" forKey:@"publicStatus"];
            [currentUser setObject:@"YES" forKey:@"joinedPublic"];
            [currentUser saveInBackground];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        int randomNumber = [self getRandomNumberBetween:1 to:100];
        
        if (randomNumber < 30)
        {
            [self performSegueWithIdentifier: @"publicZombie" sender: self];
            [currentUser setObject:@"zombie" forKey:@"publicStatus"];
            [currentUser setObject:@"YES" forKey:@"joinedPublic"];
            [currentUser saveInBackground];
        }
        else
        {
            [self performSegueWithIdentifier: @"publicSurvivor" sender: self];
            [currentUser setObject:@"survivor" forKey:@"publicStatus"];
            [currentUser setObject:@"YES" forKey:@"joinedPublic"];
            [currentUser saveInBackground];
        }
        
        PFQuery *query = [PFQuery queryWithClassName:@"UserScore"];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        PFObject *theUserScore = [query getFirstObject];
        float score = [theUserScore[@"publicScore"] floatValue];
        float points = 5000.0f;
        NSNumber *sum = [NSNumber numberWithFloat:score - points];
        [theUserScore setObject:sum forKey:@"publicScore"];
        [theUserScore saveInBackground];
    }
    else
    {
        //Do nothing
    }
}

//Method that chooses a random number
-(int)getRandomNumberBetween:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
