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
    
    self.currentUser = [PFUser currentUser];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationItem.hidesBackButton = YES;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    [self saveLocation];
    
    //When user is on the menu, checks every minute for their location
    self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(saveLocation) userInfo:nil repeats:YES];
}

- (void)saveLocation
{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        [self.currentUser setObject:geoPoint forKey:@"location"];
        [self.currentUser saveInBackground];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.locationTimer invalidate];
}

- (IBAction)startPublicGame
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if ([self.currentUser[@"publicStatus"] isEqualToString:@"zombie"])
    {
        PublicZombieViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicZombie"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([self.currentUser[@"publicStatus"] isEqualToString:@"survivor"])
    {
        PublicSurvivorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicSurvivor"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        int randomNumber = [self getRandomNumberBetween:1 to:100];
        
        if (randomNumber < 20)
        {
            PublicZombieViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicZombie"];
            [self.navigationController pushViewController:vc animated:YES];
            [self.currentUser setObject:@"zombie" forKey:@"publicStatus"];
            [self.currentUser setObject:@"YES" forKey:@"joinedPublic"];
            [self.currentUser saveInBackground];
        }
        else
        {
            PublicSurvivorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicSurvivor"];
            [self.navigationController pushViewController:vc animated:YES];
            [self.currentUser setObject:@"survivor" forKey:@"publicStatus"];
            [self.currentUser setObject:@"YES" forKey:@"joinedPublic"];
            [self.currentUser saveInBackground];
        }
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
