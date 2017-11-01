//
//  AppDelegate.m
//  IFTTTSDK Example
//
//  Copyright © 2017 IFTTT. All rights reserved.
//

#import "AppDelegate.h"
#import <IFTTTSDK/IFTTTSDK.h>
#import <SafariServices/SafariServices.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[IFTTTAPIManager sharedManager] setServiceSlug:@"ifttt_api_example"];
    [[IFTTTAPIManager sharedManager] setInviteCode:@"21790-7d53f29b1eaca0bdc5bd6ad24b8f4e1c"];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    if ([[[[self.window rootViewController] presentedViewController] presentedViewController] isKindOfClass:[SFSafariViewController class]]) {
        [[[[self.window rootViewController] presentedViewController] presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    }
    
    return YES;
}

@end
