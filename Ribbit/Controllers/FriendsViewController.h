//
//  FriendsViewController.h
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FriendDelegate.h"

@class User;

@interface FriendsViewController : UITableViewController <FriendDelegate>

@property (nonatomic, strong) NSArray *friends;

@property (nonatomic, strong) User *currentUser;
@end
