//
//  AppDelegate.h
//  Ribbit
//
//  Created by Ben Jakuben on 7/29/13.
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;
@interface AppDelegate : UIResponder <UIApplicationDelegate, FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
