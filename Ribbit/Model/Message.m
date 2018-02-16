//
//  Message.m
//  Ribbit
//
//  Created by Amit Bijlani on 8/25/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

#import "Message.h"

@import Firebase;

@interface Message()
@property (strong, nonatomic) NSMutableArray *messagesMutable;

@end

@implementation Message
// Logic for partner Id. So Only messages that were sent to current user show up in inbox, no duplicates no sent messages either
- (NSString *)chatPartnerId {
    NSString *chatPartner;
    
    if (self.fromId == [FIRAuth auth].currentUser.uid) {
        chatPartner = self.toId;
    } else {
        chatPartner = self.fromId;
    }
    
    return chatPartner;
}
// Init methods
- (id)initWithDictionary:(NSDictionary *)dict {
    
    if ((self = [super init])) {
        self.fromId = [dict objectForKey:@"fromId"];
        self.toId = [dict objectForKey:@"toId"];
        self.imageUrl = [dict objectForKey:@"imageUrl"];
        self.contentType = [dict objectForKey:@"contentType"];
    }
    
    return self;
}

- (id)initWithVideoMessageDictionary:(NSDictionary *)dict {
    if ((self = [super init])) {
        self.fromId = [dict objectForKey:@"fromId"];
        self.toId = [dict objectForKey:@"toId"];
        self.videoUrl = [dict objectForKey:@"videoUrl"];
        self.contentType = [dict objectForKey:@"contentType"];
    }
    
    return self;
}
// Thanks Treehouse for this starter code that I tweaked
+ (instancetype) currentApp {
    static Message *sharedApp = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ // I learnt this was a singleton...
        sharedApp = [[self alloc] init];
        sharedApp.messagesMutable = [NSMutableArray array];
    });
    
    return sharedApp;
}

- (void) addMessage:(Message*)message {
    [self.messagesMutable addObject:message];
}

- (void) deleteMessage:(Message*)message {
    [self.messagesMutable removeObject:message];
}

- (NSMutableArray*)messages {
    return self.messagesMutable;
}

@end
