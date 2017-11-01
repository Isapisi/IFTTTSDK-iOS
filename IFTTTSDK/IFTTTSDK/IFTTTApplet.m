//
//  IFTTTApplet.m
//  IFTTTSDK
//
//  Copyright © 2017 IFTTT. All rights reserved.
//

#import "IFTTTApplet.h"
#import "IFTTTApplet+Private.h"
#import "IFTTTService+Private.h"
#import "IFTTTAPIManager+Private.h"

@interface IFTTTApplet ()

@property NSString *identifier;
@property NSString *name;
@property NSString *appletDescription;
@property NSDate *publishedAt;
@property NSUInteger enabledCount;
@property NSURL *url;
@property NSURL *embeddedUrl;

@property enum IFTTTAppletStatus status;
@property NSDate *lastRunAt;

@property IFTTTService *primaryService;
@property NSArray<IFTTTService*> *secondaryServices;

@end

@implementation IFTTTApplet

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    });
    return formatter;
}

+ (instancetype)appletWithDictionary:(NSDictionary *)dictionary
{
    IFTTTApplet *applet = [IFTTTApplet new];
    
    if ([dictionary[@"id"] isKindOfClass:[NSString class]]) {
        applet.identifier = dictionary[@"id"];
    }
    
    if ([dictionary[@"name"] isKindOfClass:[NSString class]]) {
        applet.name = dictionary[@"name"];
    }
    
    if ([dictionary[@"description"] isKindOfClass:[NSString class]]) {
        applet.appletDescription = dictionary[@"description"];
    }
    
    if ([dictionary[@"published_at"] isKindOfClass:[NSString class]]) {
        applet.publishedAt = [[IFTTTApplet dateFormatter] dateFromString:dictionary[@"published_at"]];
    }
    
    if ([dictionary[@"enabled_count"] isKindOfClass:[NSNumber class]]) {
        applet.enabledCount = [(NSNumber*)dictionary[@"enabled_count"] unsignedIntegerValue];
    }
    
    if ([dictionary[@"url"] isKindOfClass:[NSString class]]) {
        applet.url = [NSURL URLWithString:dictionary[@"url"]];
    }
    
    if ([dictionary[@"embedded_url"] isKindOfClass:[NSString class]]) {
        applet.embeddedUrl = [NSURL URLWithString:dictionary[@"embedded_url"]];
    }
    
    if ([dictionary[@"user_status"] isKindOfClass:[NSString class]]) {
        NSString *statusString = dictionary[@"user_status"];
        if ([statusString isEqualToString:@"enabled"]) {
            applet.status = IFTTTAppletStatusEnabled;
        } else if ([statusString isEqualToString:@"disabled"]) {
            applet.status = IFTTTAppletStatusDisabled;
        } else if ([statusString isEqualToString:@"never_enabled"]) {
            applet.status = IFTTTAppletStatusNeverEnabled;
        } else {
            // An unexpected status string
            return nil;
        }
    }
    
    if ([dictionary[@"last_run_at"] isKindOfClass:[NSString class]]) {
        applet.lastRunAt = [[IFTTTApplet dateFormatter] dateFromString:dictionary[@"last_run_at"]];
    }
    
    if ([dictionary[@"services"] isKindOfClass:[NSArray class]]) {
        NSArray *serviceDictionaries = dictionary[@"services"];
        NSMutableArray *secondaryServices = [NSMutableArray array];
        for (NSDictionary *serviceDictionary in serviceDictionaries) {
            if ([serviceDictionary isKindOfClass:[NSDictionary class]]) {
                IFTTTService *service = [IFTTTService serviceWithDictionary:serviceDictionary];
                if (service != nil) {
                    BOOL primary = NO;
                    if ([serviceDictionary[@"is_primary"] isKindOfClass:[NSNumber class]]) {
                        primary = [(NSNumber*)serviceDictionary[@"is_primary"] boolValue];
                    }
                    if (primary) {
                        applet.primaryService = service;
                    } else {
                        [secondaryServices addObject:service];
                    }
                }
            }
        }
        applet.secondaryServices = [NSArray arrayWithArray:secondaryServices];
    }
    
    if (applet.identifier == nil || applet.name == nil || applet.appletDescription == nil || applet.publishedAt == nil ||
        applet.url == nil || applet.embeddedUrl == nil || applet.primaryService == nil) {
        return nil;
    }
    
    return applet;
}

- (NSURL *)embeddedUrlWithCallbackUrl:(NSURL *)callbackUrl email:(NSString *)email userId:(NSString *)userId
{
    NSAssert([callbackUrl isKindOfClass:[NSURL class]], @"Must provide a valid callback URL");
    NSAssert([userId isKindOfClass:[NSString class]] && userId.length > 0, @"Must provide a valid user id");
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.embeddedUrl resolvingAgainstBaseURL:NO];
    
    NSMutableArray<NSURLQueryItem*> *queryItems = [NSMutableArray array];
    
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"ifttt_sdk_version" value:[IFTTTAPIManager versionString]]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"ifttt_sdk_platform" value:@"ios"]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"ifttt_sdk_anonymous_id" value:[[IFTTTAPIManager sharedManager] anonymousId]]];
    
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"user_id" value:userId]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"redirect_uri" value:callbackUrl.absoluteString]];
    
    if ([[IFTTTAPIManager sharedManager] inviteCode].length != 0) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"invite_code" value:[[IFTTTAPIManager sharedManager] inviteCode]]];
    }
    [components setQueryItems:queryItems];

    NSURL *url = [components URL];
    
    if ([email isKindOfClass:[NSString class]] && email.length > 0) {
        // NSURLComponents encodes "+" as " ", which is not correct in the case of an email.
        // So we'll encode the email and append it to the end of the URL manually.
        email = [email stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        url = [NSURL URLWithString:[url.absoluteString stringByAppendingString:[NSString stringWithFormat:@"&email=%@", email]]];
    }
    
    return url;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<IFTTTApplet: %@ (%@...)>",
            self.identifier,
            [self.name substringToIndex:MIN(self.name.length, 25)]
            ];
}

@end
