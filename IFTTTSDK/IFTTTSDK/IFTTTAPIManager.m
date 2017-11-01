//
//  IFTTTAPIManager.m
//  IFTTTSDK
//
//  Copyright © 2017 IFTTT. All rights reserved.
//

#import "IFTTTAPIManager+Private.h"
#import "IFTTTApplet+Private.h"
#import "IFTTTUser+Private.h"

@implementation IFTTTAPIManager

+ (IFTTTAPIManager *)sharedManager
{
    static IFTTTAPIManager *sharedAPIManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAPIManager = [IFTTTAPIManager new];
    });
    return sharedAPIManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.apiHost = @"api.ifttt.com";
        self.anonymousId = [[NSUUID UUID] UUIDString];
    }
    return self;
}

+ (NSString *)versionString
{
    // UPDATEME: Don't forget to update this when the version changes!
    return @"0.0.1";
}

- (NSMutableURLRequest *)requestWithPath:(NSString *)path method:(NSString *)method queryItems:(NSArray<NSURLQueryItem*>*)queryItems
{
    NSURLComponents *urlComponents = [NSURLComponents new];
    [urlComponents setScheme:@"https"];
    [urlComponents setHost:self.apiHost];
    [urlComponents setPath:path];
    [urlComponents setQueryItems:queryItems];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[urlComponents URL]];
    [request setHTTPMethod:method];
    if ([method isEqualToString:@"POST"]) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    [request setValue:@"ios" forHTTPHeaderField:@"IFTTT-SDK-Platform"];
    [request setValue:[IFTTTAPIManager versionString] forHTTPHeaderField:@"IFTTT-SDK-Version"];
    [request setValue:self.anonymousId forHTTPHeaderField:@"IFTTT-SDK-Anonymous-Id"];
    
    if (self.userToken.length > 0) {
        [request setValue:[NSString stringWithFormat:@"Bearer %@", self.userToken] forHTTPHeaderField:@"Authorization"];
    }
    
    if (self.inviteCode.length > 0) {
        [request setValue:self.inviteCode forHTTPHeaderField:@"IFTTT-Invite-Code"];
    }

    return request;
}

- (void)fetchAppletsInOrder:(IFTTTOrderType)orderType platform:(IFTTTPlatformType)platform completion:(void (^)(NSArray<IFTTTApplet *> * _Nullable, NSError * _Nullable))completion
{
    NSAssert(self.serviceSlug.length > 0, @"Please set a service slug before making requests");
    
    NSMutableArray *queryItems = [NSMutableArray array];
    
    NSString *orderString = nil;
    switch (orderType) {
        case IFTTTOrderTypePublishedAtAscending:
            orderString = @"published_at_asc";
            break;
        case IFTTTOrderTypePublishedAtDescending:
            orderString = @"published_at_desc";
            break;
        case IFTTTOrderTypeEnabledCountAscending:
            orderString = @"enabled_count_asc";
            break;
        case IFTTTOrderTypeEnabledCountDescending:
            orderString = @"enabled_count_desc";
            break;
        case IFTTTOrderTypeDefault:
            break;
    }
    if (orderString.length > 0) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"order" value:orderString]];
    }
    
    switch (platform) {
        case IFTTTPlatformTypeIos:
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"platform" value:@"ios"]];
            break;
        case IFTTTPlatformTypeAndroid:
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"platform" value:@"android"]];
            break;
        case IFTTTPlatformTypeNone: break;
    }
    
    NSURLRequest *request = [self requestWithPath:[NSString stringWithFormat:@"/v1/services/%@/applets", self.serviceSlug] method:@"GET" queryItems:queryItems];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                completion(nil, error);
                return;
            }
            if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                NSError *jsonError = nil;
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (jsonError != nil) {
                    completion(nil, jsonError);
                    return;
                }
                NSMutableArray<IFTTTApplet*> *applets = [NSMutableArray array];
                if ([[responseDictionary objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
                    NSArray *appletDictionaries = [responseDictionary objectForKey:@"data"];
                    for (NSDictionary *appletDictionary in appletDictionaries) {
                        if ([appletDictionary isKindOfClass:[NSDictionary class]]) {
                            IFTTTApplet *applet = [IFTTTApplet appletWithDictionary:appletDictionary];
                            if (applet) {
                                [applets addObject:applet];
                            }
                        }
                    }
                }
                completion(applets, nil);
            } else {
                completion(nil, [NSError errorWithDomain:NSURLErrorDomain code:[(NSHTTPURLResponse *)response statusCode] userInfo:nil]);
            }
        });
    }];
    [task resume];
}

- (void)handleAppletResponseWithData:(NSData *_Nullable)data response:(NSURLResponse *_Nullable)response error:(NSError *_Nullable)error completion:(void (^)(IFTTTApplet * _Nullable, NSError * _Nullable))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            NSError *jsonError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                completion(nil, jsonError);
                return;
            }
            IFTTTApplet *applet = [IFTTTApplet appletWithDictionary:responseDictionary];
            completion(applet, nil);
        } else {
            completion(nil, [NSError errorWithDomain:NSURLErrorDomain code:[(NSHTTPURLResponse *)response statusCode] userInfo:nil]);
        }
    });
}

- (void)fetchAppletWithId:(NSString *)appletId completion:(void (^)(IFTTTApplet * _Nullable, NSError * _Nullable))completion
{
    NSAssert(appletId.length > 0, @"Invalid Applet ID");

    NSURLRequest *request = [self requestWithPath:[NSString stringWithFormat:@"/v1/services/%@/applets/%@", self.serviceSlug, appletId] method:@"GET" queryItems:nil];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self handleAppletResponseWithData:data response:response error:error completion:completion];
    }];
    [task resume];
}

- (void)setStatus:(BOOL)enabled forAppletId:(NSString *_Nonnull)appletId completion:(void (^)(IFTTTApplet * _Nullable, NSError * _Nullable))completion
{
    NSAssert(appletId.length > 0, @"Invalid Applet ID");
    
    NSURLRequest *request = [self requestWithPath:[NSString stringWithFormat:@"/v1/services/%@/applets/%@/%@", self.serviceSlug, appletId, (enabled ? @"enable" : @"disable")] method:@"POST" queryItems:nil];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self handleAppletResponseWithData:data response:response error:error completion:completion];
    }];
    [task resume];
}

- (void)fetchCurrentUserWithCompletion:(void (^)(IFTTTUser * _Nullable, NSError * _Nullable))completion
{
    if (self.userToken.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, nil);
        });
        return;
    }
    
    NSURLRequest *request = [self requestWithPath:@"/v1/me" method:@"GET" queryItems:nil];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                NSError *jsonError = nil;
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (jsonError) {
                    completion(nil, jsonError);
                    return;
                } else if ([[responseDictionary objectForKey:@"user_login"] isKindOfClass:[NSString class]]) {
                    NSString *username = [responseDictionary objectForKey:@"user_login"];
                    IFTTTUser *user = [[IFTTTUser alloc] initWithUsername:username];
                    completion(user, nil);
                    return;
                }
            } else {
                completion(nil, [NSError errorWithDomain:NSURLErrorDomain code:[(NSHTTPURLResponse *)response statusCode] userInfo:nil]);
            }
        });
    }];
    [task resume];
}

@end
