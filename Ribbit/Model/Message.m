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

@interface Message()
@property (strong, nonatomic) NSMutableArray *messagesMutable;

@end
@implementation Message

- (void)saveInBackgroundWithBlock:(BooleanResultBlock)block {
  
  [[App currentApp] addMessage:self];
  block(YES,nil);
}

- (NSString *)chatPartnerId {
    NSString *chatPartner;
    
    if (self.fromId == [FIRAuth auth].currentUser.uid) {
        NSLog(@"INSIDE CHAT PARTNER: %@", self.fromId);
        chatPartner = self.toId;
    } else {
        chatPartner = self.fromId;
    }
    
    return chatPartner;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    
    if ((self = [super init])) {
        self.fromId = [dict objectForKey:@"fromId"];
        self.toId = [dict objectForKey:@"toId"];
        self.imageUrl = [dict objectForKey:@"imageUrl"];
    }
    
    return self;
}

+ (instancetype) currentApp {
    static Message *sharedApp = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
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

- (NSArray*)messages {
    return self.messagesMutable;
}


@end
