//
//  RibbitUser.h
//  Ribbit
//
//  Created by Max Ramirez on 2/1/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDelegate.h"

@import Firebase;

@interface RibbitUser : NSObject
{
    id<UserDelegate> delegate;
}

@property (nonatomic, retain) id<UserDelegate> delegate;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *id;

@property (strong, nonatomic) NSString *friendName;


+ (instancetype)currentRibitUser;
+ (instancetype)userWithUsername:(NSString*)username;

//- (void)addFriend:(RibbitUser *)friend;
//- (void)removeFriend:(RibbitUser *)friend;
- (id)initWithDictionary:(NSDictionary *)dict;
- (id)initWithFriendDictionary:(NSDictionary *)dict;
- (NSArray*) friends;
@end
