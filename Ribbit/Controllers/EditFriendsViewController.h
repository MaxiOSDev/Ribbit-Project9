//
//  EditFriendsViewController.h
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendDelegate.h"
@class User;

@interface EditFriendsViewController : UITableViewController
{
    id<FriendDelegate> delegate;
}

@property (nonatomic, retain) id<FriendDelegate> delegate;
@property (nonatomic, strong) User *currentUser;
@property (strong,nonatomic) NSArray *friends;
@property (strong, nonatomic) NSMutableArray *mutableFriendsArray;

- (BOOL)isFriend:(User *)user;

@end






