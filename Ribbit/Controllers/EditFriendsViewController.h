//
//  EditFriendsViewController.h
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FriendDelegate.h"
#import "RibbitUser.h"
@class User;

@interface EditFriendsViewController : UITableViewController
{
    id<FriendDelegate> delegate;
}
// Stored properties
@property (nonatomic, retain) id<FriendDelegate> delegate;
@property (strong,nonatomic) NSArray *friends;
@property (strong, nonatomic) NSMutableArray *mutableFriendsArray;
@property (nonatomic,strong) RibbitUser *currentRibbitUser;
@property (strong, nonatomic) NSMutableArray *users;
- (BOOL)isFriend:(RibbitUser *)user;

@end






