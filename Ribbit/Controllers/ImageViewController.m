//
//  ImageViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "ImageViewController.h"
#import "Message.h"

#import "UIImageView+CacheExtension.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Checks if imageURLString is nil
    if (self.imageUrlString != nil) {
        [self.imageView loadImageUsingCacheWithUrlString:self.message.imageUrl];
    } else {
        NSLog(@"Image is nil");
    }

    NSString *title = [NSString stringWithFormat:@"Sent from %@", self.senderName]; // Supposed to make title the fromId's username.
    self.navigationItem.title = title;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self respondsToSelector:@selector(timeout)]) {
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeout) userInfo:nil repeats:NO]; // Starter code, after 10 seconds takes me back to inboxVC
    }
    else {
        NSLog(@"Error: selector missing!");
    }
}

#pragma mark - Helper methods

- (void)timeout {
    [self.navigationController popViewControllerAnimated:YES];
}

@end























