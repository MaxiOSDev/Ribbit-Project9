//
//  FriendDelegate.h
//  Ribbit
//
//  Created by Max Ramirez on 1/29/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RibbitUser;
@protocol FriendDelegate <NSObject>
@optional
-(void)didMarkAsFriendDelegate:(RibbitUser *)user;
@end






