//
//  AppletsTableViewController.h
//  IFTTTSDK Example
//
//  Copyright © 2017 IFTTT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IFTTTApplet;

@interface AppletsTableViewController : UITableViewController

@property NSArray<IFTTTApplet*> *applets;

@end
