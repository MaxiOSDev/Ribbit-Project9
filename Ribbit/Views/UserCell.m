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

- (void)setMessage:(Message*)message {
    _message = message;
    
    NSString *id = self.message.chatPartnerId;
    NSLog(@"Chat Partner ID here: %@", id);
    
        FIRDatabaseReference *ref = [[[FIRDatabase.database reference] child:@"users"] child:id];
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                NSDictionary *dict = snapshot.value;
                self.nameLabel.text= dict[@"name"];
        } withCancelBlock:nil];
}

@end











