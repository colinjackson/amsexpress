//
//  AMSNotesMasterViewController.h
//  AMS Express
//
//  Created by Colin on 7/29/14.
//  Copyright (c) 2014 Alpert Medical School. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMSNotesDetailViewController;

@interface AMSNotesMasterViewController : UITableViewController

@property (strong, nonatomic) AMSNotesDetailViewController *detailViewController;

@end
