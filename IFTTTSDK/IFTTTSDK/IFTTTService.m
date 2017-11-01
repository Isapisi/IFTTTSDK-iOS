//
//  IFTTTService.m
//  IFTTTSDK
//
//  Copyright © 2017 IFTTT. All rights reserved.
//

#import "IFTTTService.h"
#import "IFTTTService+Private.h"

@interface UIColor (IFTTTHex)

+ (UIColor *)colorWithHexString:(NSString *)string;

@end

@implementation UIColor (IFTTTHex)

+ (UIColor *)colorWithHexString:(NSString *)string
{
    unsigned int value = 0;
    NSString *hexString = [string stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&value];
    
    return [UIColor colorWithRed:((value & 0xFF0000) >> 16)/255.f green:((value & 0xFF00) >> 8)/255.f blue:(value & 0xFF)/255.f alpha:1.0];
}

@end

@interface IFTTTService ()

@property NSString *slug;
@property NSString *name;
@property NSURL *monochromeIconUrl;
@property NSURL *colorIconUrl;
@property UIColor *brandColor;
@property NSURL *url;

@end

@implementation IFTTTService

+ (instancetype)serviceWithDictionary:(NSDictionary *)dictionary
{
    IFTTTService *service = [IFTTTService new];
    
    if ([dictionary[@"service_id"] isKindOfClass:[NSString class]]) {
        service.slug = dictionary[@"service_id"];
    }
    
    if ([dictionary[@"service_name"] isKindOfClass:[NSString class]]) {
        service.name = dictionary[@"service_name"];
    }
    
    if ([dictionary[@"monochrome_icon_url"] isKindOfClass:[NSString class]]) {
        service.monochromeIconUrl = [NSURL URLWithString:dictionary[@"monochrome_icon_url"]];
    }

    if ([dictionary[@"color_icon_url"] isKindOfClass:[NSString class]]) {
        service.colorIconUrl = [NSURL URLWithString:dictionary[@"color_icon_url"]];
    }
    
    if ([dictionary[@"brand_color"] isKindOfClass:[NSString class]]) {
        service.brandColor = [UIColor colorWithHexString:dictionary[@"brand_color"]];
    }
    
    if ([dictionary[@"url"] isKindOfClass:[NSString class]]) {
        service.url = [NSURL URLWithString:dictionary[@"url"]];
    }
    
    if (service.slug == nil || service.name == nil ||
        service.monochromeIconUrl == nil || service.colorIconUrl == nil ||
        service.brandColor == nil || service.url == nil) {
        return nil;
    }
    
    return service;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<IFTTTService: %@ (%@)>",
            self.slug,
            self.name
            ];
}

@end
