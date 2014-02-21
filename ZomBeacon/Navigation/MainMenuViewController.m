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
    
    if ([PFUser currentUser]) {
        [[PFUser currentUser] refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        }];
    }
    
    self.currentUser = [PFUser currentUser];
    self.findPrivateGameButton.titleLabel.font = [UIFont fontWithName:@"04B_19" size:self.findPrivateGameButton.titleLabel.font.pointSize];
    self.startPublicGameButton.titleLabel.font = [UIFont fontWithName:@"04B_19" size:self.startPublicGameButton.titleLabel.font.pointSize];
    self.createPrivateGameButton.titleLabel.font = [UIFont fontWithName:@"04B_19" size:self.createPrivateGameButton.titleLabel.font.pointSize];
}

- (void)viewDidAppear:(BOOL)animated
{
//    //Checks to see if the public game start date was more than 7 days ago
//    PFQuery *publicGameStart = [PFQuery queryWithClassName:@"PublicGame"];
//    PFObject *currentPublicGame = [publicGameStart getFirstObject];
//    NSDate *startDate = currentPublicGame[@"startDate"];
//    NSInteger daysBetween = [self daysBetweenDate:startDate andDate:[NSDate date]];
//    
//    if (daysBetween > 7)
//    {
//        [[PFUser currentUser] setObject:@"" forKey:@"publicStatus"];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PUBLIC GAME RESET" message:@"A new public game has started, your status has been reset!" delegate:nil cancelButtonTitle:@"Yay!" otherButtonTitles:nil];
//        
//        [alert show];
//    }
    
    self.navigationItem.hidesBackButton = YES;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    [self saveLocation];
    
    //When user is on the menu, checks every minute for their location
    self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(saveLocation) userInfo:nil repeats:YES];
}

//- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
//{
//    NSDate *fromDate;
//    NSDate *toDate;
//    
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    
//    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
//                 interval:NULL forDate:fromDateTime];
//    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
//                 interval:NULL forDate:toDateTime];
//    
//    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
//                                               fromDate:fromDate toDate:toDate options:0];
//    
//    return [difference day];
//}

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
