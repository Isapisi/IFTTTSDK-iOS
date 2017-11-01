//
//  ExampleAppAPIManager.h
//  IFTTTSDK Example
//
//  Copyright © 2017 IFTTT. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This class is used to communicate with the API of the example app. You can learn more about
 the example app here: https://github.com/IFTTT/ifttt-api-example
 */
@interface ExampleAppAPIManager : NSObject

+ (ExampleAppAPIManager *)sharedManager;

@property NSString *exampleAppUserId;
@property NSString *exampleAppToken;
@property NSString *exampleAppEmail;

- (void)fetchExampleAppTokenWithCompletion:(void (^)(BOOL))completion;
- (void)fetchIftttTokenWithCompletion:(void (^)(NSString *))completion;
- (void)fetchLoginUrlWithRedirectUrl:(NSURL *)redirectUrl completion:(void (^)(NSURL *))completion;

@end
