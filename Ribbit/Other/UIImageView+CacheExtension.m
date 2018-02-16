//
//  UIImageView+CacheExtension.m
//  Ribbit
//
//  Created by Max Ramirez on 2/2/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

#import "UIImageView+CacheExtension.h"

@implementation UIImageView (CacheExtension)
// Cache extension method
- (UIImageView *)loadImageUsingCacheWithUrlString:(NSString *)urlString {
    
    NSCache *imageCache = [[NSCache alloc] init];
    
    self.image = nil;
    
    UIImage *cachedImage = [imageCache objectForKey:urlString];
        self.image = cachedImage;
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error);
        }
        
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        UIImage *downloadedImage = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageCache setObject:downloadedImage forKey:urlString];
            self.image = downloadedImage;
        });
        
    }];
    [task resume];
    
    return self;
}

@end
