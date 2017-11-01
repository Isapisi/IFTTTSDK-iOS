//
//  IFTTTAPIManager.h
//  IFTTTSDK
//
//  Copyright © 2017 IFTTT. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Requests that the ordering for returned Applets from the IFTTT API.

 - IFTTTOrderTypeDefault: Default ordering.
 - IFTTTOrderTypePublishedAtAscending: Oldest Applets first.
 - IFTTTOrderTypePublishedAtDescending: Newest Applets first.
 - IFTTTOrderTypeEnabledCountAscending: Least used Applets first.
 - IFTTTOrderTypeEnabledCountDescending: Most used Applets first.
 */
typedef NS_ENUM(NSUInteger, IFTTTOrderType) {
    IFTTTOrderTypeDefault,
    IFTTTOrderTypePublishedAtAscending,
    IFTTTOrderTypePublishedAtDescending,
    IFTTTOrderTypeEnabledCountAscending,
    IFTTTOrderTypeEnabledCountDescending
};

/**
 Requests Applets that only use a certain mobile platform.

 - IFTTTPlatformTypeNone: Excludes any Applets that use mobile services.
 - IFTTTPlatformTypeIos: Excludes any Applets that use non-iOS mobile services.
 - IFTTTPlatformTypeAndroid: Excludes any Applets that use non-Android mobile services.
 */
typedef NS_ENUM(NSUInteger, IFTTTPlatformType) {
    IFTTTPlatformTypeNone,
    IFTTTPlatformTypeIos,
    IFTTTPlatformTypeAndroid
};

@class IFTTTApplet, IFTTTUser;

/**
 Use this class for all requests to the IFTTT API. You should not instantiate
 your own, but instead always use sharedManager.
 */
@interface IFTTTAPIManager : NSObject

/**
 A singleton IFTTTAPIManager used for all IFTTT API requests.

 @return the shared singleton
 */
+ (IFTTTAPIManager *_Nonnull)sharedManager;

/**
 The host of the IFTTT API to be used. Defaults to api.ifttt.com.
 
 @note You can change this property to point to your own backend server that
 acts as a proxy to the IFTTT API. This allows you to use service-based
 authentication by adding a service key header on the backend.
 */
@property (copy) NSString *_Nonnull apiHost;

/**
 Your IFTTT service's slug. This must be set before making any requests.
 */
@property (copy) NSString *_Nullable serviceSlug;

/**
 A token fetched from the IFTTT API that identifies the current user on IFTTT.
 Any requests made after setting this property will use it for authentication.
 */
@property (copy) NSString *_Nullable userToken;

/**
 Include your invite code if your service has not been published on IFTTT.
 This will allow you to test flows end to end as a user new to IFTTT.
 */
@property (copy) NSString *_Nullable inviteCode;

/**
 Fetches your service's Applets.

 @param orderType The method used to sort the returned list of Applets.
 @param platform Specifies the mobile platform desired for Applets.
 @param completion A block that will be called passing an array of Applets or an error if the request failed.
 
 @note The completion block will always be called on the main thread.
 */
- (void)fetchAppletsInOrder:(IFTTTOrderType)orderType platform:(IFTTTPlatformType)platform completion:(void (^_Nonnull)(NSArray<IFTTTApplet*> *_Nullable applets, NSError *_Nullable error))completion;

/**
 Fetch an individual Applet from your service.

 @param appletId The ID of the Applet.
 @param completion A block that will be called passing the Applet or an error.
 
 @note The completion block will always be called on the main thread.
 
 */
- (void)fetchAppletWithId:(NSString *_Nonnull)appletId completion:(void (^_Nonnull)(IFTTTApplet *_Nullable applet, NSError *_Nullable error))completion;

/**
 Change the status of one of your service's Applets on behalf of a user.

 @param enabled The new status of the Applet.
 @param appletId The ID of the Applet.
 @param completion A block that will be called, passing the updated Applet or an error if the request failed.
 
 @note The completion block will always be called on the main thread.
 @warning This method will only work if the status of the Applet in question is
 IFTTTAppletStatusEnabled or IFTTTAppletStatusDisabled. For IFTTTAppletStatusNeverEnabled, use the activation process described in README.
 
 */
- (void)setStatus:(BOOL)enabled forAppletId:(NSString *_Nonnull)appletId completion:(void (^_Nonnull)(IFTTTApplet *_Nullable applet, NSError *_Nullable error))completion;

/**
 Fetch the current IFTTT user based on the provided userToken.
 Note: if userToken is nil, the callback will be called immediately.

 @param completion A block that will be called, passing a user object or an error if the request failed.
 */
- (void)fetchCurrentUserWithCompletion:(void (^_Nonnull)(IFTTTUser *_Nullable user, NSError *_Nullable error))completion;

@end
