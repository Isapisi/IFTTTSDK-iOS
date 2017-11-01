//
//  IFTTTApplet.h
//  IFTTTSDK
//
//  Copyright © 2017 IFTTT. All rights reserved.
//

@import Foundation;

/**
 Represents the various states of an Applet

 - IFTTTAppletStatusUnknown: Returned for Applets from unauthenticated API
 requests.
 - IFTTTAppletStatusEnabled: The Applet is activated and running.
 - IFTTTAppletStatusDisabled: The Applet is activated but currently disabled.
 - IFTTTAppletStatusNeverEnabled: The Applet has not been activated by the user.
 */
typedef NS_ENUM(NSUInteger, IFTTTAppletStatus) {
    IFTTTAppletStatusUnknown,
    IFTTTAppletStatusEnabled,
    IFTTTAppletStatusDisabled,
    IFTTTAppletStatusNeverEnabled
};

@class IFTTTService;

/**
 An Applet on the IFTTT platform.
 
 @note You should not instantiate IFTTTApplet objects directly. Instead, fetch
 them from the IFTTT API using [IFTTTAPIManager sharedManager].
 */
@interface IFTTTApplet : NSObject

/**
 The ID of the Applet.
 */
@property (readonly) NSString *_Nonnull identifier;

/**
 The name of the Applet.
 */
@property (readonly) NSString *_Nonnull name;

/**
 The description of the Applet.
 */
@property (readonly) NSString *_Nonnull appletDescription;

/**
 The date the Applet was originally published.
 */
@property (readonly) NSDate *_Nonnull publishedAt;

/**
 The number of IFTTT users that have turned on the Applet.
 */
@property (readonly) NSUInteger enabledCount;

/**
 The Applet's canonical URL on IFTTT.
 */
@property (readonly) NSURL *_Nonnull url;

/**
 The current status of the Applet for the current user.
 
 @note status will be IFTTTAppletStatusUnknown if the Applet was returned from
 an unauthenticated API request.
 */
@property (readonly) enum IFTTTAppletStatus status;

/**
 The last successful run of this Applet for the current user.
 
 @note lastRunAt will be nil if the Applet was returned from an unauthenticated
 API request or if it has never run for the current user.
 */
@property (readonly) NSDate *_Nullable lastRunAt;

/**
 The service that "owns" this Applet. In general, this will be your service.
 primaryService is used on IFTTT to customize Applets' icon and color.
 */
@property (readonly) IFTTTService *_Nonnull primaryService;

/**
 An array of other services whose triggers or actions are used by the Applet.
 */
@property (readonly) NSArray<IFTTTService*> *_Nonnull secondaryServices;

/**
 Use this method to generate a URL that can be used to display the Applet in
 a web view. In iOS 9+, we strongly encourage using an SFSafariViewController.

 @param callbackUrl A callback URL registered on the IFTTT platform that will
 be called when the user finishes the Applet flow.
 @param email Pass the current user's email to simplify the IFTTT signup
 process. We will not store this value until the user creates an IFTTT account.
 @return A URL to be opened in a web view.
 @param userId The current user's identifier on your service that will be used
 when they connect to IFTTT.

 @note Make sure the scheme used in your callback URL is registered in your
 Info.plist and added to your approved redirects on the IFTTT platform.
 */
- (NSURL *_Nonnull)embeddedUrlWithCallbackUrl:(NSURL *_Nonnull)callbackUrl email:(NSString *_Nullable)email userId:(NSString *_Nonnull)userId;

@end
