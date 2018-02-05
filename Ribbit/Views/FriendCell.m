//
//  FriendCell.m
//  Ribbit
//
//  Created by Max Ramirez on 2/5/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

#import "FriendCell.h"
#import "RibbitUser.h"

@implementation FriendCell

-(void)setFriend:(RibbitUser *)friend {
    _friend = friend;
    
    FIRDatabaseReference *ref = [[[FIRDatabase.database reference] child:@"users"] child:friend.ribbitFriendId];
    NSLog(@"The id: %@", friend.id);
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *dict = snapshot.value;
        self.nameLabel.text = dict[@"name"];
    } withCancelBlock:nil];
    
}

@end
