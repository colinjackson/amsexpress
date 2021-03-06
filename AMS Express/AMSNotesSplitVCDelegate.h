//
//  AMSNotesSplitVCDelegate.h
//  AMS Express
//
//  Created by Colin on 7/30/14.
//  Copyright (c) 2014 Alpert Medical School. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMSNotesMasterViewController;

@interface AMSNotesSplitVCDelegate : NSObject <UISplitViewControllerDelegate>

@property (nonatomic, weak) AMSNotesMasterViewController *masterVC;
@property (nonatomic, weak) UINavigationController *detailNavigationVC;

@end
