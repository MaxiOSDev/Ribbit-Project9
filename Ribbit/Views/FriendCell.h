//
//  FriendCell.h
//  Ribbit
//
//  Created by Max Ramirez on 2/5/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class RibbitUser;
@interface FriendCell : UITableViewCell

@property (strong, nonatomic) RibbitUser *friend;
- (void)setFriend:(RibbitUser*)friend;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
