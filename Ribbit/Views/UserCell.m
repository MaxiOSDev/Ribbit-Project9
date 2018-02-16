//
//  UserCell.m
//  Ribbit
//
//  Created by Max Ramirez on 2/2/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

#import "UserCell.h"
#import "Message.h"


@import Firebase;

@implementation UserCell
// Sets messages in each cell
- (void)setMessage:(Message*)message {
    _message = message;
    NSString *fromId = [FIRAuth.auth currentUser].uid;
    NSString *messageFromId = message.fromId;
    // Logic that took me quite a while to think of in my head
    if ([fromId isEqualToString:messageFromId]) {
        FIRDatabaseReference *ref = [[[FIRDatabase.database reference] child:@"users"] child:message.toId];
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSDictionary *dict = snapshot.value;
            self.nameLabel.text= dict[@"name"];
        } withCancelBlock:nil];
    } else {
        FIRDatabaseReference *ref = [[[FIRDatabase.database reference] child:@"users"] child:message.fromId];
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSDictionary *dict = snapshot.value;
            self.nameLabel.text= dict[@"name"];
        } withCancelBlock:nil];
    }

}

@end











