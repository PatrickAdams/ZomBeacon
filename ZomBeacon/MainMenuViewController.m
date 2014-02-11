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
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationItem.hidesBackButton = YES;
    [currentUser setObject:@"" forKey:@"currentGame"];
    [currentUser saveInBackground];
}

- (IBAction)startPublicGame
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    if ([currentUser[@"publicStatus"] isEqualToString:@"zombie"])
    {
        PublicZombieViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicZombie"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([currentUser[@"publicStatus"] isEqualToString:@"survivor"])
    {
        PublicSurvivorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicSurvivor"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        int randomNumber = [self getRandomNumberBetween:1 to:100];

        if (randomNumber < 10)
        {
            PublicZombieViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicZombie"];
            [self.navigationController pushViewController:vc animated:YES];
            [currentUser setObject:@"zombie" forKey:@"publicStatus"];
            [currentUser setObject:@"YES" forKey:@"joinedPublic"];
            [currentUser saveInBackground];
        }
        else
        {
            PublicSurvivorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicSurvivor"];
            [self.navigationController pushViewController:vc animated:YES];
            [currentUser setObject:@"survivor" forKey:@"publicStatus"];
            [currentUser setObject:@"YES" forKey:@"joinedPublic"];
            [currentUser saveInBackground];
        }
    }
}

//- (IBAction)startPublicGame
//{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//
//    PublicZombieViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicZombie"];
//    [self.navigationController pushViewController:vc animated:YES];
//    [currentUser setObject:@"zombie" forKey:@"publicStatus"];
//    [currentUser setObject:@"YES" forKey:@"joinedPublic"];
//    [currentUser saveInBackground];
//}
//
//- (IBAction)startPublicGame
//{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    
//    PublicSurvivorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"publicSurvivor"];
//    [self.navigationController pushViewController:vc animated:YES];
//    [currentUser setObject:@"survivor" forKey:@"publicStatus"];
//    [currentUser setObject:@"YES" forKey:@"joinedPublic"];
//    [currentUser saveInBackground];
//}

//Method that chooses a random number
-(int)getRandomNumberBetween:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
}

//Method that logs the user out with the Parse framework
- (IBAction)logUserOut
{
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
