//
//  IFTTTUser.h
//  IFTTTSDK
//
//  Copyright © 2017 IFTTT. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A user on the IFTTT service.
 */
@interface IFTTTUser : NSObject

/**
 The user's login. This is automatically generated based on the user's
 email address, though they can change it in IFTTT settings.
 */
@property (readonly) NSString *_Nonnull username;

@end
