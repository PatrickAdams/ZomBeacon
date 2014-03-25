//
//  LoginViewController.m
//  ZomBeacon
//
//  Created by Patrick Adams on 1/6/14.
//  Copyright (c) 2014 Patrick Adams. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    self.navigationItem.hidesBackButton = YES;
    
    [super viewDidLoad];
    
    PFUser *currentUser = [PFUser currentUser];
    
    //Checks to make sure a user is logged in, if so, it skips the login screen
    if (currentUser)
    {
        [self performSegueWithIdentifier:@"mainmenu" sender:self];
    }
    
    for (UILabel * label in self.titilliumSemiBoldFonts) {
        label.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:label.font.pointSize];
    }
    
    //Provides indentation for the textfields
    for (UITextField * textField in self.textFieldSpacers) {
        UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7.5, 7.5)];
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setLeftView:spacerView];
    }
    
    self.forgotPasswordButton.titleLabel.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:self.forgotPasswordButton.titleLabel.font.pointSize];
    
    self.signUpButton.titleLabel.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:self.signUpButton.titleLabel.font.pointSize];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:22],
      NSFontAttributeName, [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1], NSForegroundColorAttributeName, nil]];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    //Reset fields when view loads
    self.usernameField.text = @"";
    self.passwordField.text = @"";
}

#pragma mark - User Login Methods - Normal, Facebook, and Twitter

//Method to log in the user using the Parse framework
-(IBAction)logInUser
{
    [self.passwordField resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *username = self.usernameField.text;
        NSString *password = self.passwordField.text;
        
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error)
         {
             if (user)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                 });
                 
                 [self performSegueWithIdentifier:@"tutorial" sender:self];
                 [self performSegueWithIdentifier:@"mainmenu" sender:self];
                 
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Successful!" message:@"You are now logged in." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 
                 [alert show];
             }
             else
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                 });
                 
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", [error userInfo][@"error"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 
                 [alert show];
             }
         }];
    });
}

- (IBAction)logInWithFacebook
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // The permissions requested from the user
        NSArray *permissionsArray = @[ @"user_about_me", @"email"];
        
        // Login PFUser using Facebook
        [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error)
         {
             if (!user)
             {
                 if (!error)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                     });
                     NSLog(@"Uh oh. The user cancelled the Facebook login.");
                 }
                 else
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                     });
                     NSLog(@"Uh oh. An error occurred: %@", error);
                 }
             }
             else if (user.isNew)
             {
                 [self performSegueWithIdentifier:@"tutorial" sender:self];
                 [self performSegueWithIdentifier:@"mainmenu" sender:self];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                 });
                 
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign up successful!" message:@"You are now logged in." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 
                 [alert show];
                 
                 // Create request for user's Facebook data
                 FBRequest *request = [FBRequest requestForMe];
                 
                 // Send request to Facebook
                 [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
                  {
                      if (!error)
                      {
                          // result is a dictionary with the user's Facebook data
                          NSDictionary *userData = (NSDictionary *)result;
                          
                          PFUser *currentUser = [PFUser currentUser];
                          currentUser.username = userData[@"username"];
                          currentUser.email = userData[@"email"];
                          currentUser[@"name"] = userData[@"name"];
                          currentUser[@"bio"] = userData[@"bio"];
                          currentUser[@"minor"] = [NSNumber numberWithInt:[self getRandomNumberBetween:0 to:65535]];
                          currentUser[@"major"] = [NSNumber numberWithInt:[self getRandomNumberBetween:0 to:65535]];
                          
                          //Create the UserScore row for the currentUser
                          PFObject *userScore = [PFObject objectWithClassName:@"UserScore"];
                          [userScore setObject:currentUser forKey:@"user"];
                          [userScore saveInBackground];
                          
                          [currentUser saveInBackground];
                          
                          // Download the user's facebook profile picture
                          self.imageData = [[NSMutableData alloc] init];
                          
                          NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userData[@"id"]]];
                          
                          NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0f];
                          
                          NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
                          NSLog(@"%@", urlConnection);
                      }
                  }];
             }
             else
             {
                 [self performSegueWithIdentifier:@"mainmenu" sender:self];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                 });
                 
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Successful!" message:@"You are now logged in." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 
                 [alert show];
             }
         }];
    });
}

-(IBAction)loginWithTwitter
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
            if (!user)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
                NSLog(@"Uh oh. The user cancelled the Twitter login.");
            }
            else if(user.isNew)
            {
                [self performSegueWithIdentifier:@"tutorial" sender:self];
                [self performSegueWithIdentifier:@"mainmenu" sender:self];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign up successful!" message:@"You are now logged in." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
                
                NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
                NSURL *verify = [NSURL URLWithString:requestString];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
                [[PFTwitterUtils twitter] signRequest:request];
                NSURLResponse *response = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                
                if (error == nil)
                {
                    NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                    
                    PFUser *currentUser = [PFUser currentUser];
                    currentUser.username = [result objectForKey:@"screen_name"];
                    currentUser[@"name"] = [result objectForKey:@"name"];
                    currentUser[@"bio"] = [result objectForKey:@"description"];
                    currentUser[@"minor"] = [NSNumber numberWithInt:[self getRandomNumberBetween:0 to:65535]];
                    currentUser[@"major"] = [NSNumber numberWithInt:[self getRandomNumberBetween:0 to:65535]];
                    
                    //Create the UserScore row for the currentUser
                    PFObject *userScore = [PFObject objectWithClassName:@"UserScore"];
                    [userScore setObject:currentUser forKey:@"user"];
                    [userScore saveInBackground];
                    
                    [currentUser saveInBackground];
                    
                    // Download the user's twitter profile picture
                    self.imageData = [[NSMutableData alloc] init];
                    
                    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [result objectForKey:@"profile_image_url_https"]]];
                    
                    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0f];
                    
                    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
                    NSLog(@"%@", urlConnection);
                }
            }
            else
            {
                [self performSegueWithIdentifier:@"mainmenu" sender:self];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Successful!" message:@"You are now logged in." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
            }
        }];
    });
}

#pragma mark - Image Download Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}

//Once the image is done downloading, it saves it to the imageFile value for that User
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    PFFile *file = [[query getFirstObject] objectForKey:@"imageFile"];
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:self.imageData];
    
    if (!file)
    {
        // Save PFFile
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (!error)
             {
                 PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
                 [userPhoto setObject:imageFile forKey:@"imageFile"];
                 [userPhoto setObject:[PFUser currentUser] forKey:@"user"];
                 [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     
                 }];
             }
         }];
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
