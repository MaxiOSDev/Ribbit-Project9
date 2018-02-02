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

@end
