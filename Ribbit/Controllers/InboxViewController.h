//
//  InboxViewController.h
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@class Message;

@interface InboxViewController : UITableViewController <UITabBarControllerDelegate>
// Stored properties and 1 IBAction
@property (nonatomic, strong) Message *selectedMessage;
@property (nonatomic, strong) Message *inboxMessage;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) AVPlayerViewController *moviePlayer;
@property (strong, nonatomic) NSMutableArray *users;

- (IBAction)logout:(id)sender;


@end
