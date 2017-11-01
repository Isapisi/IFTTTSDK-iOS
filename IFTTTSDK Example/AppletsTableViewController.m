//
//  AppletsTableViewController.m
//  IFTTTSDK Example
//
//  Copyright © 2017 IFTTT. All rights reserved.
//

#import "AppletsTableViewController.h"
#import "ExampleAppAPIManager.h"

#import <IFTTTSDK/IFTTTSDK.h>

@import SafariServices;

@interface AppletsTableViewController ()

@end

@interface AppletCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *imageViewContainer;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *worksWithLabel;

@property (copy) NSURL *imageURL;

@end

@implementation AppletCell
@end

@implementation AppletsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    self.navigationItem.title = @"Applets";
    
    [self refreshUser];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // The current user might have an IFTTT account associated with them now,
    // so we should check if that's so and refresh the Applets with whatever
    // token (or none) is returned.
    [self refreshIftttTokenAndApplets];
}

- (void)doneButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshIftttTokenAndApplets
{
    [[ExampleAppAPIManager sharedManager] fetchIftttTokenWithCompletion:^(NSString *token) {
        [[IFTTTAPIManager sharedManager] setUserToken:token];
        [self refreshApplets];
        [self refreshUser];
    }];
}

- (void)refreshUser
{
    [[IFTTTAPIManager sharedManager] fetchCurrentUserWithCompletion:^(IFTTTUser * _Nullable user, NSError * _Nullable error) {
        if (user.username.length > 0) {
            self.navigationItem.title = [NSString stringWithFormat:@"Applets (%@)", user.username];
        } else {
            self.navigationItem.title = @"Applets (no IFTTT user)";
        }
    }];
}

- (void)refreshApplets
{
    [[IFTTTAPIManager sharedManager] fetchAppletsInOrder:IFTTTOrderTypeDefault platform:IFTTTPlatformTypeIos completion:^(NSArray<IFTTTApplet *> * _Nullable applets, NSError * _Nullable error) {
        if (applets) {
            self.applets = applets;
            [self.tableView reloadData];
        }
    }];
}

- (void)updateApplet:(IFTTTApplet *)applet atIndex:(NSUInteger)index
{
    NSMutableArray *applets = [NSMutableArray arrayWithArray:self.applets];
    [applets replaceObjectAtIndex:index withObject:applet];
    self.applets = [NSArray arrayWithArray:applets];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.applets.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IFTTTApplet *applet = [self.applets objectAtIndex:indexPath.row];
    
    AppletCell *cell = (AppletCell*)[tableView dequeueReusableCellWithIdentifier:@"applet-cell" forIndexPath:indexPath];
    
    cell.nameLabel.text = applet.name;
    cell.descriptionLabel.text = applet.appletDescription;

    NSMutableArray<NSString*> *otherNames = [NSMutableArray array];
    for (IFTTTService *service in applet.secondaryServices) {
        [otherNames addObject:service.name];
    }
    cell.worksWithLabel.text = [NSString stringWithFormat:@"Works with: %@", [otherNames componentsJoinedByString:@", "]];
    
    switch (applet.status) {
        case IFTTTAppletStatusUnknown: cell.statusLabel.text = nil; break;
        case IFTTTAppletStatusEnabled: cell.statusLabel.text = @"Status: Enabled"; break;
        case IFTTTAppletStatusDisabled: cell.statusLabel.text = @"Status: Disabled"; break;
        case IFTTTAppletStatusNeverEnabled: cell.statusLabel.text = @"Status: Never enabled"; break;
    }
    
    IFTTTService *brandService = applet.secondaryServices.firstObject ?: applet.primaryService;

    cell.imageViewContainer.backgroundColor = brandService.brandColor;
    cell.imageViewContainer.layer.cornerRadius = 5;
    
    NSURL *imageURL = brandService.colorIconUrl;
    if ([cell.imageURL isEqual:imageURL] == NO) {
        cell.iconImageView.image = nil;
    }

    cell.imageURL = imageURL;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([cell.imageURL isEqual:imageURL]) {
                cell.iconImageView.image = [UIImage imageWithData:imageData];
            }
        });
    });

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IFTTTApplet *applet = [self.applets objectAtIndex:indexPath.row];
    NSURL *appletUrl = [applet embeddedUrlWithCallbackUrl:[NSURL URLWithString:@"ifttt-api-example://sdk-callback"]
                                                    email:[[ExampleAppAPIManager sharedManager] exampleAppEmail]
                                                   userId:[[ExampleAppAPIManager sharedManager] exampleAppUserId]];
    
    if (applet.status == IFTTTAppletStatusNeverEnabled || applet.status == IFTTTAppletStatusUnknown) {
        [self openURLWithLoginRedirect:appletUrl];
    } else {
        BOOL enabled = applet.status == IFTTTAppletStatusEnabled;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:applet.name message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"View on IFTTT" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openURLWithLoginRedirect:appletUrl];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:enabled ? @"Disable Applet" : @"Enable Applet" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[IFTTTAPIManager sharedManager] setStatus:!enabled forAppletId:applet.identifier completion:^(IFTTTApplet * _Nullable updatedApplet, NSError * _Nullable error) {
                if (updatedApplet) {
                    [self updateApplet:updatedApplet atIndex:indexPath.row];
                }
            }];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Refresh Applet" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[IFTTTAPIManager sharedManager] fetchAppletWithId:applet.identifier completion:^(IFTTTApplet * _Nullable updatedApplet, NSError * _Nullable error) {
                if (updatedApplet) {
                    [self updateApplet:updatedApplet atIndex:indexPath.row];
                }
            }];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)openURLWithLoginRedirect:(NSURL*)url
{
    [[ExampleAppAPIManager sharedManager] fetchLoginUrlWithRedirectUrl:url completion:^(NSURL *loginUrl) {
        if (loginUrl == nil) {
            loginUrl = url;
        }
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:loginUrl];
        [self presentViewController:safariViewController animated:YES completion:nil];
    }];
}

@end
