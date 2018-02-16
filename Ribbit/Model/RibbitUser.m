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
// Starter code
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

- (NSArray*) friends {
    return self.friendsMutable;
}
// Init methods
- (id)initWithDictionary:(NSDictionary *)dict {
    
    if ((self = [super init])) {
        self.id = [dict objectForKey:@"id"];
        self.name = [dict objectForKey:@"name"];
        self.email = [dict objectForKey:@"email"];
    }
    
    return self;
}

- (id)initWithFriendDictionary:(NSDictionary *)dict {
    
    if ((self = [super init])) {
        self.friendName = [dict objectForKey:@"friendName"];
        self.friendId = [dict objectForKey:@"friendId"];
    }
    
    return self;
}

@end









