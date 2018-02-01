//
//  RibbitUser.m
//  Ribbit
//
//  Created by Max Ramirez on 2/1/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

#import "RibbitUser.h"
@import Firebase;

static NSInteger identifier = 1;

@interface RibbitUser()
@property (strong, nonatomic) NSMutableArray *friendsMutable;
@end

@implementation RibbitUser
@synthesize delegate;

+ (instancetype)currentRibitUser {
    static RibbitUser *sharedUser = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUser = [[self alloc] init];
        sharedUser.name = @"Current User";
        sharedUser.objectId = @"100";
        sharedUser.friendsMutable = [NSMutableArray array];
    });
    
    return sharedUser;
}

+ (instancetype)userWithUsername:(NSString*)username {
    RibbitUser *user = [[self alloc] init];
    if ( user ) {
        user.name = username;
        user.objectId = [NSString stringWithFormat:@"%ld",(long)++identifier];
    }
    return user;
}

- (void)addFriend:(RibbitUser *)friend {
    [self.friendsMutable addObject:friend];
}

- (void)removeFriend:(RibbitUser *)friend {
    if ([self.friends containsObject:friend]) {
        [self.friendsMutable removeObject:friend];
    }
}

- (NSArray*) friends {
    return self.friendsMutable;
}


@end


