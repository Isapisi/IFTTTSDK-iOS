//
//  IFTTTSDKTests.m
//  IFTTTSDKTests
//
//  Copyright © 2017 IFTTT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IFTTTAPIManager+Private.h"

@interface IFTTTSDKTests : XCTestCase

@end

@implementation IFTTTSDKTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    NSString *versionString = [IFTTTAPIManager versionString];
    NSDictionary *infoDictionary = [NSBundle bundleForClass:[IFTTTAPIManager class]].infoDictionary;
    NSString *bundleVersionString = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    XCTAssert([versionString isEqualToString:bundleVersionString], @"Hardcoded version string doesn't match framework version string");
}

@end
