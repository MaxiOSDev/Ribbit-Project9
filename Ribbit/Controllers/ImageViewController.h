//
//  ImageViewController.h
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Message;

@interface ImageViewController : UIViewController
// Stored Properties and IBOutlet
@property (nonatomic, strong) Message *message;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSString *senderName;
@property (nonatomic, strong) NSString *imageUrlString;

@end
