//
//  ExampleAppAPIManager.m
//  IFTTTSDK Example
//
//  Copyright © 2017 IFTTT. All rights reserved.
//

#import "ExampleAppAPIManager.h"

@implementation ExampleAppAPIManager

+ (ExampleAppAPIManager *)sharedManager
{
    static ExampleAppAPIManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [ExampleAppAPIManager new];
    });
    return manager;
}

- (void)fetchExampleAppTokenWithCompletion:(void (^)(BOOL))completion
{
    if (self.exampleAppUserId.length == 0) {
        completion(NO);
        return;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ifttt-api-example.herokuapp.com/mobile_api/log_in?username=%@", self.exampleAppUserId]]];
    [request setHTTPMethod:@"POST"];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([response isKindOfClass:[NSHTTPURLResponse class]] && [(NSHTTPURLResponse *)response statusCode] == 200) {
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                self.exampleAppToken = responseDictionary[@"token"];
                if (completion) {
                    completion(self.exampleAppToken != nil);
                }
            } else {
                if (completion) {
                    completion(NO);
                }
            }
        });
    }];
    [task resume];
}

- (void)fetchIftttTokenWithCompletion:(void (^)(NSString *))completion
{
    if (self.exampleAppToken.length == 0) {
        completion(nil);
        return;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ifttt-api-example.herokuapp.com/mobile_api/get_ifttt_token"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.exampleAppToken] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *token = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]] && [(NSHTTPURLResponse *)response statusCode] == 200) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([responseDictionary[@"token"] isKindOfClass:[NSString class]]) {
                token = responseDictionary[@"token"];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(token);
            }
        });
    }];
    [task resume];
}

- (void)fetchLoginUrlWithRedirectUrl:(NSURL *)redirectUrl completion:(void (^)(NSURL *))completion
{
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:@"http://ifttt-api-example.herokuapp.com/mobile_api/get_login_url"];
    [urlComponents setQueryItems:@[[NSURLQueryItem queryItemWithName:@"redirect_to" value:redirectUrl.absoluteString]]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[urlComponents URL]];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [[ExampleAppAPIManager sharedManager] exampleAppToken]] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"POST"];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([response isKindOfClass:[NSHTTPURLResponse class]] && [(NSHTTPURLResponse *)response statusCode] == 200) {
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (completion) {
                    completion([NSURL URLWithString:responseDictionary[@"login_url"]]);
                }
            } else {
                if (completion) {
                    completion(nil);
                }
            }
        });
    }];
    [task resume];

}

@end
