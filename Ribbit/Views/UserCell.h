//
//  UserCell.h
//  Ribbit
//
//  Created by Max Ramirez on 2/2/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class Message;

@interface UserCell : UITableViewCell

@property (strong, nonatomic) Message *message;

- (void)setMessage:(Message*)message;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
