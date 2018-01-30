//
//  User.h
//  Ribbit
//
//  Created by Amit Bijlani on 8/24/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "App.h"
#import "UserDelegate.h"

@interface User : NSObject
{
    id<UserDelegate> delegate;
}

@property (nonatomic, retain) id<UserDelegate> delegate;
@property (strong,nonatomic) NSString *objectId;
@property (copy,nonatomic) NSString *username;
@property (copy,nonatomic) NSString *password;
@property (copy,nonatomic) NSString *email;

+ (instancetype)currentUser;
+ (instancetype)userWithUsername:(NSString*)username;

- (void)addFriend:(User *)friend;
- (void)removeFriend:(User *)friend;
- (NSArray*) friends;

@end
