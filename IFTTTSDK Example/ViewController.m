//
//  ViewController.m
//  IFTTTSDK Example
//
//  Copyright © 2017 IFTTT. All rights reserved.
//

#import "ViewController.h"
#import <IFTTTSDK/IFTTTSDK.h>
#import "AppletsTableViewController.h"
#import "ExampleAppAPIManager.h"

static NSString *usernameDefaultsKey = @"username";
static NSString *emailDefaultsKey = @"email";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.activityIndicator.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self promptForSignIn];
}

- (void)promptForSignIn
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Sign in to example service" message:@"Any username will do" preferredStyle:UIAlertControllerStyleAlert];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setPlaceholder:@"username"];
        if (@available(iOS 11.0, *)) {
            [textField setTextContentType:UITextContentTypeUsername];
        }
        [textField setText:[[NSUserDefaults standardUserDefaults] stringForKey:usernameDefaultsKey]];
    }];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setPlaceholder:@"email (optional)"];
        [textField setTextContentType:UITextContentTypeEmailAddress];
        [textField setKeyboardType:UIKeyboardTypeEmailAddress];
        [textField setText:[[NSUserDefaults standardUserDefaults] stringForKey:emailDefaultsKey]];
    }];
    [controller addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray<UITextField*> *textFields = [controller textFields];
        NSString *username = [[textFields objectAtIndex:0] text];
        NSString *email = [[textFields objectAtIndex:1] text];
        
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:usernameDefaultsKey];
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:emailDefaultsKey];
        
        if ([username length] == 0) {
            [self promptForSignIn];
        } else {
            [self signInWithUsername:username email:email];
        }
    }]];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)signInWithUsername:(NSString *)username email:(NSString *)email
{
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    
    [[ExampleAppAPIManager sharedManager] setExampleAppToken:nil];
    [[ExampleAppAPIManager sharedManager] setExampleAppEmail:email];
    [[IFTTTAPIManager sharedManager] setUserToken:nil];
    
    [[ExampleAppAPIManager sharedManager] setExampleAppUserId:username];
    [[ExampleAppAPIManager sharedManager] fetchExampleAppTokenWithCompletion:^(BOOL success) {
        if (success) {
            [self fetchIftttUserToken];
        } else {
            [self showNetworkError];
        }
    }];
}

- (void)fetchIftttUserToken
{
    [[ExampleAppAPIManager sharedManager] fetchIftttTokenWithCompletion:^(NSString *token) {
        [[IFTTTAPIManager sharedManager] setUserToken:token];
        [self fetchApplets];
    }];    
}

- (void)fetchApplets
{
    [[IFTTTAPIManager sharedManager] fetchAppletsInOrder:IFTTTOrderTypeDefault platform:IFTTTPlatformTypeIos completion:^(NSArray<IFTTTApplet *> * _Nullable applets, NSError * _Nullable error) {
        if (error != nil) {
            [self showNetworkError];
            return;
        }
        [self performSegueWithIdentifier:@"ShowApplets" sender:applets];
        [self.activityIndicator setHidden:YES];
    }];
}

- (void)showNetworkError
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error loading Applets" message:@"Please try again" preferredStyle:UIAlertControllerStyleActionSheet];
    [controller addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self promptForSignIn];
    }]];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AppletsTableViewController *appletsTableViewController = (AppletsTableViewController*)[(UINavigationController* )[segue destinationViewController] topViewController];
    appletsTableViewController.applets = sender;
}

@end
