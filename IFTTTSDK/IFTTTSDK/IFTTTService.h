//
//  IFTTTService.h
//  IFTTTSDK
//
//  Copyright © 2017 IFTTT. All rights reserved.
//

@import Foundation;
@import UIKit;

/**
 A service on the IFTTT platform.
 */
@interface IFTTTService : NSObject

/**
 The service's slug.
 */
@property (readonly) NSString *_Nonnull slug;

/**
 The service's name.
 */
@property (readonly) NSString *_Nonnull name;

/**
 A URL of the service's monochrome (or "Works with") icon.
 This icon is safe to place on colors other than the service's brand color.
 */
@property (readonly) NSURL *_Nonnull monochromeIconUrl;

/**
 A URL of the service's full-color icon.
 This icon is only safe to place on top of the service's brand color.
 */
@property (readonly) NSURL *_Nonnull colorIconUrl;

/**
 The service's brand color.
 */
@property (readonly) UIColor *_Nonnull brandColor;

/**
 The service's canonical URL on IFTTT.
 */
@property (readonly) NSURL *_Nonnull url;

@end
