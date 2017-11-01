//
//  IFTTTUser.m
//  IFTTTSDK
//
//  Copyright © 2017 IFTTT. All rights reserved.
//

#import "IFTTTUser.h"
#import "IFTTTUser+Private.h"

@interface IFTTTUser ()

@property NSString *username;

@end

@implementation IFTTTUser

- (instancetype)initWithUsername:(NSString *)username
{
    self = [super init];
    if (self) {
        self.username = username;
    }
    return self;
}

@end
