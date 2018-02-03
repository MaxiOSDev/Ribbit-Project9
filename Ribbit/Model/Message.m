//
//  Message.m
//  Ribbit
//
//  Created by Amit Bijlani on 8/25/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

#import "Message.h"
#import "App.h"
@import Firebase;

@implementation Message

- (void)saveInBackgroundWithBlock:(BooleanResultBlock)block {
  
  [[App currentApp] addMessage:self];
  block(YES,nil);
}

- (NSString *)chatPartnerId {
    return self.fromId == [[FIRAuth.auth currentUser] uid] ? self.toId : self.fromId;
}

+ (instancetype)initWithDict:(NSDictionary *)dict {
    Message *message = [[self alloc] init];
    
    message.fromId = [dict objectForKey:@"id"];
    message.toId = [dict objectForKey:@"toId"];
    message.imageUrl = [dict objectForKey:@"imageUrl"];
    
    return message;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    
    if ((self = [super init])) {
        self.fromId = [dict objectForKey:@"fromId"];
        self.toId = [dict objectForKey:@"toId"];
        self.imageUrl = [dict objectForKey:@"imageUrl"];
    }
    
    return self;
}


@end
